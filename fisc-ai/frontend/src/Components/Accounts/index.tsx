import React, { useEffect, useState } from 'react'
import './Accounts.css';

interface Account {
  account_id: string;
  name: string;
  type: string;
  balance: {
    current: number;
    available: number;
    limit: number;
  };
  mask: string;
  institution_name: string;
  status: string;
}

interface AccountsProps {
  API_BASE_URL: string;
}

const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(amount);
};

const Accounts: React.FC<AccountsProps> = ({ API_BASE_URL }) => {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastFetchTime, setLastFetchTime] = useState<number | null>(null);

  const shouldFetchData = () => {
    if (!lastFetchTime) return true;
    const fiveMinutes = 5 * 60 * 1000;
    return Date.now() - lastFetchTime > fiveMinutes;
  };

  const fetchAccounts = async () => {
    if (!shouldFetchData() && accounts.length > 0) {
      console.log("Using cached accounts data");
      return;
    }

    try {
      setLoading(true);
      console.log("🔄 Fetching accounts...");

      const response = await fetch(`${API_BASE_URL}/fetch_accounts_dynamo`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json();
        console.error("❌ Accounts fetch error:", errorData);
        throw new Error(`Failed to fetch accounts: ${errorData.error || response.statusText}`);
      }

      const data = await response.json();
      console.log("✅ Raw accounts data:", data);
      
      if (data.accounts && Array.isArray(data.accounts)) {
        setAccounts(data.accounts);
        setLastFetchTime(Date.now());
        setError(null);
      } else {
        console.error("❌ Unexpected response structure:", data);
        throw new Error("Invalid response format from server");
      }
    } catch (err) {
      console.error("❌ Error fetching accounts:", err);
      setError(err instanceof Error ? err.message : "Failed to fetch accounts");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAccounts();
  }, []);

  const getAccountIcon = (type: string) => {
    switch (type.toLowerCase()) {
      case 'credit':
        return '💳';
      case 'depository':
        return '🏦';
      case 'investment':
        return '📈';
      case 'loan':
        return '🏠';
      default:
        return '💰';
    }
  };

  if (loading) {
    return (
      <div className="accounts-container">
        <div className="account-card">
          <div className="account-header">
            <div className="account-icon">...</div>
            <div className="account-info">
              <h3 className="account-name">Loading...</h3>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="accounts-container">
        <div className="account-card">
          <div className="account-header">
            <div className="account-icon">⚠️</div>
            <div className="account-info">
              <h3 className="account-name">Error</h3>
              <p className="account-type">{error}</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="accounts-container">
      {accounts.map((account) => (
        <div key={account.account_id} className="account-card">
          <div className="account-header">
            <div className="account-icon">{getAccountIcon(account.type)}</div>
            <div className="account-info">
              <h3 className="account-name">{account.name}</h3>
              <p className="account-type">{account.institution_name}</p>
            </div>
          </div>
          
          <div className="account-balance">
            {formatCurrency(account.balance.current)}
          </div>
          
          <div className="account-details">
            <div className="detail-item">
              <span className="detail-label">Available</span>
              <span className="detail-value">
                {formatCurrency(account.balance.available)}
              </span>
            </div>
            <div className="detail-item">
              <span className="detail-label">Type</span>
              <span className="detail-value">{account.type}</span>
            </div>
            <div className="detail-item">
              <span className="detail-label">Last 4</span>
              <span className="detail-value">{account.mask}</span>
            </div>
            {account.balance.limit > 0 && (
              <div className="detail-item">
                <span className="detail-label">Limit</span>
                <span className="detail-value">
                  {formatCurrency(account.balance.limit)}
                </span>
              </div>
            )}
          </div>
          
          <div className="account-status">
            {account.status}
          </div>
        </div>
      ))}
    </div>
  );
};

export default Accounts; 