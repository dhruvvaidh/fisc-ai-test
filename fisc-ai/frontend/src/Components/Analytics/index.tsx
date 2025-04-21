import React, { useState, useEffect } from 'react';
import styles from './Analytics.module.css';

interface AnalyticsProps {
  accessToken: string;
  API_BASE_URL: string;
  userId: string;
}

interface Transaction {
  amount: number;
  date: string;
  personal_finance_category?: {
    primary: string;
  };
}

const Analytics: React.FC<AnalyticsProps> = ({ accessToken, API_BASE_URL, userId }) => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        setIsLoading(true);
        
        const response = await fetch(`${API_BASE_URL}/fetch_transactions_dynamo`, {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          }
        });

        if (!response.ok) {
          throw new Error('Failed to fetch transactions');
        }

        const data = await response.json();
        setTransactions(data.transactions || []);
      } catch (error) {
        console.error('Error fetching analytics:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchAnalytics();
  }, [API_BASE_URL]);

  // Calculate totals and summaries
  const calculateSummaries = () => {
    const categoryTotals = new Map<string, number>();
    let totalSpending = 0;

    transactions.forEach(transaction => {
      const amount = Math.abs(transaction.amount);
      const category = transaction.personal_finance_category?.primary || 'Other';
      
      categoryTotals.set(category, (categoryTotals.get(category) || 0) + amount);
      totalSpending += amount;
    });

    return {
      categoryTotals: Array.from(categoryTotals.entries()),
      totalSpending
    };
  };

  const { categoryTotals, totalSpending } = calculateSummaries();

  if (isLoading) {
    return <div className={styles.loadingState}>Loading analytics...</div>;
  }

  return (
    <div className={styles.analyticsContainer}>
      <h2 className={styles.sectionTitle}>Financial Analytics</h2>

      {/* Total Spending */}
      <div className={styles.analyticsSection}>
        <h3 className={styles.sectionTitle}>Total Spending</h3>
        <div className={styles.totalAmount}>
          ${totalSpending.toLocaleString()}
        </div>
      </div>

      {/* Category Breakdown */}
      <div className={styles.analyticsSection}>
        <h3 className={styles.sectionTitle}>Spending by Category</h3>
        <div className={styles.categoryGrid}>
          {categoryTotals.map(([category, amount]) => (
            <div key={category} className={styles.categoryCard}>
              <div className={styles.categoryName}>{category}</div>
              <div className={styles.categoryAmount}>
                ${amount.toLocaleString()}
              </div>
              <div className={styles.categoryPercentage}>
                {((amount / totalSpending) * 100).toFixed(1)}%
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Transaction Count */}
      <div className={styles.analyticsSection}>
        <h3 className={styles.sectionTitle}>Transaction Summary</h3>
        <div className={styles.summaryText}>
          Total Transactions: {transactions.length}
        </div>
      </div>
    </div>
  );
};

export default Analytics;
