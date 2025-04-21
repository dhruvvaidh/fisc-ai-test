import React, { useEffect, useState, useCallback } from 'react';
import { Table, TableHead, TableRow, TableCell, TableBody } from '@aws-amplify/ui-react';
import styles from './Transactions.module.css';

interface Counterparty {
  name: string;
  type: string;
  website: string | null;
  logo_url: string | null;
  confidence_level: string;
  entity_id: string | null;
  phone_number: string | null;
}

interface Transaction {
  account_id: string;
  amount: number;
  category: string[];
  date: string;
  merchant_name: string | null;
  name: string;
  payment_channel: string;
  pending: boolean;
  transaction_type: string;
  logo_url: string | null;
  transaction_id: string;
  counterparties: Counterparty[];
  personal_finance_category: {
    primary: string;
    detailed: string;
    confidence_level: string;
  };
}

interface TransactionsProps {
  transactions: Transaction[];
  accessToken: string;
  API_BASE_URL: string;
  userId: string;
}

const Transactions = ({ accessToken, API_BASE_URL, userId }: TransactionsProps) => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isUploadModalOpen, setIsUploadModalOpen] = useState(false);

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      month: 'short', 
      day: '2-digit', 
      year: 'numeric' 
    });
  };

  const handleRefresh = useCallback(async () => {
    setIsLoading(true);
    try {
      // Implement the refresh logic here
    } catch (error) {
      console.error('Error refreshing transactions:', error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  return (
    <div className={styles['transactions-container']}>
      <div className={styles['transactions-header']}>
        <div className={styles['header-left']}>
          <h2 className={styles['header-title']}>Your Transactions</h2>
          <span className={styles['transaction-count']}>
            ({transactions.length} total)
          </span>
        </div>
        <div className={styles['header-actions']}>
          <button 
            onClick={handleRefresh}
            className={styles['action-button']}
            disabled={isLoading}
          >
            Refresh
          </button>
          <button 
            onClick={() => setIsUploadModalOpen(true)}
            className={`${styles['action-button']} ${styles['primary']}`}
          >
            Upload Receipt
          </button>
        </div>
      </div>
      <Table highlightOnHover={true} variation="striped">
        <TableHead>
          <TableRow>
            <TableCell as="th">Date</TableCell>
            <TableCell as="th">Merchant</TableCell>
            <TableCell as="th">Category</TableCell>
            <TableCell as="th">Amount</TableCell>
            <TableCell as="th">Status</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {transactions.length ? (
            transactions.map((transaction) => (
              <TableRow key={transaction.transaction_id}>
                <TableCell>{formatDate(transaction.date)}</TableCell>
                <TableCell>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    {transaction.logo_url && (
                      <img
                        src={transaction.logo_url}
                        alt={transaction.merchant_name || transaction.name}
                        style={{ width: '24px', height: '24px', borderRadius: '50%' }}
                      />
                    )}
                    {transaction.merchant_name || transaction.name}
                  </div>
                </TableCell>
                <TableCell>{transaction.personal_finance_category.primary}</TableCell>
                <TableCell style={{ color: transaction.amount < 0 ? '#d32f2f' : '#2e7d32' }}>
                  {formatAmount(transaction.amount)}
                </TableCell>
                <TableCell>{transaction.pending ? 'Pending' : 'Completed'}</TableCell>
              </TableRow>
            ))
          ) : (
            <TableRow>
              <TableCell colSpan={5}>No transactions found</TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
};

export default Transactions;