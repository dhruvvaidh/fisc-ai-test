import React, { useState } from 'react';
import { InstitutionData } from './index';
import './Institutions.css';

interface InstitutionProps {
  institution: InstitutionData;
}

const Institution: React.FC<InstitutionProps> = ({ institution }) => {
  const [activeTab, setActiveTab] = useState<'accounts' | 'products' | 'settings'>('accounts');

  const formatCurrency = (amount: number): string => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(amount);
  };

  const getAccountIcon = (type: string): string => {
    switch (type.toLowerCase()) {
      case 'credit':
        return '💳';
      case 'checking':
        return '🏦';
      case 'savings':
        return '🏆';
      default:
        return '💰';
    }
  };

  const getProductIcon = (product: string): string => {
    switch (product.toLowerCase()) {
      case 'transactions':
        return '📊';
      case 'auth':
        return '🔐';
      case 'identity':
        return '👤';
      default:
        return '📦';
    }
  };

  const getProductDescription = (product: string): string => {
    switch (product.toLowerCase()) {
      case 'transactions':
        return 'Access to transaction history and real-time updates';
      case 'auth':
        return 'Secure access to account and routing numbers';
      case 'identity':
        return 'Verified identity and account holder information';
      default:
        return 'Additional banking services and features';
    }
  };

  const getProductMeta = (product: string) => {
    switch (product.toLowerCase()) {
      case 'transactions':
        return {
          lastSync: '2 hours ago',
          syncFrequency: 'Daily'
        };
      case 'auth':
        return {
          lastSync: '1 day ago',
          syncFrequency: 'Weekly'
        };
      case 'identity':
        return {
          lastSync: '1 week ago',
          syncFrequency: 'Monthly'
        };
      default:
        return {
          lastSync: 'N/A',
          syncFrequency: 'N/A'
        };
    }
  };

  return (
    <div className="institution-card">
      <div className="institution-header">
        {institution.logo ? (
          <img 
            src={institution.logo} 
            alt={`${institution.name} logo`} 
            className="institution-logo"
          />
        ) : (
          <div className="institution-logo">🏦</div>
        )}
        <div className="institution-info">
          <h3 className="institution-name">{institution.name}</h3>
          <span className={`status-badge ${institution.status?.toLowerCase()}`}>
            {institution.status || 'Connected'}
          </span>
        </div>
      </div>

      <div className="institution-tabs">
        <div className="tab-buttons-container">
          <button 
            className={`tab-button ${activeTab === 'accounts' ? 'active' : ''}`}
            onClick={() => setActiveTab('accounts')}
          >
            <span className="tab-icon">💳</span>
            <span className="tab-label">Accounts</span>
            {institution.accounts && 
              <span className="tab-count">{institution.accounts.length}</span>
            }
          </button>
          <button 
            className={`tab-button ${activeTab === 'products' ? 'active' : ''}`}
            onClick={() => setActiveTab('products')}
          >
            <span className="tab-icon">📦</span>
            <span className="tab-label">Products</span>
            {institution.products &&
              <span className="tab-count">{institution.products.length}</span>
            }
          </button>
          <button 
            className={`tab-button ${activeTab === 'settings' ? 'active' : ''}`}
            onClick={() => setActiveTab('settings')}
          >
            <span className="tab-icon">⚙️</span>
            <span className="tab-label">Settings</span>
          </button>
        </div>
        <div 
          className="tab-indicator" 
          style={{
            width: '33.33%',
            transform: `translateX(${activeTab === 'accounts' ? '0' : activeTab === 'products' ? '100' : '200'}%)`
          }}
        />
      </div>

      <div className="tab-content">
        {activeTab === 'accounts' && institution.accounts && (
          <div className="accounts-grid">
            {institution.accounts.map((account) => (
              <div key={`account-${account.account_id}`} className="account-row">
                <div className="account-info">
                  <div className="account-icon">
                    {getAccountIcon(account.type)}
                  </div>
                  <div>
                    <div className="account-name">{account.name}</div>
                    <div className="account-type">{account.type}</div>
                  </div>
                </div>
                <div className="account-balance">
                  {formatCurrency(account.balances?.current || 0)}
                </div>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'products' && (
          <div className="products-section">
            {institution.products?.map((product) => {
              const meta = getProductMeta(product);
              return (
                <div key={`product-${product}`} className="product-row">
                  <div className="product-icon">
                    {getProductIcon(product)}
                  </div>
                  <div className="product-info">
                    <div className="product-name">
                      {product.charAt(0).toUpperCase() + product.slice(1)}
                    </div>
                    <div className="product-description">
                      {getProductDescription(product)}
                    </div>
                    <div className="product-status">
                      <span className="product-status-badge active">
                        <span className="status-dot"></span>
                        Active
                      </span>
                    </div>
                    <div className="product-meta">
                      <div className="product-meta-item">
                        <span>🕒</span>
                        Last sync: {meta.lastSync}
                      </div>
                      <div className="product-meta-item">
                        <span>🔄</span>
                        Sync frequency: {meta.syncFrequency}
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {activeTab === 'settings' && (
          <div className="settings-section">
            <div className="setting-group">
              <div className="setting-group-title">
                <span>🔍</span>
                Connection Details
              </div>
              <div className="setting-row">
                <div className="setting-label">
                  <span>🏦</span>
                  Institution ID
                </div>
                <div className="setting-value">{institution.institution_id}</div>
              </div>
              <div className="setting-row">
                <div className="setting-label">
                  <span>📅</span>
                  Connected Since
                </div>
                <div className="setting-value">March 15, 2024</div>
              </div>
              <div className="setting-row">
                <div className="setting-label">
                  <span>🔄</span>
                  Last Sync
                </div>
                <div className="setting-value">2 hours ago</div>
              </div>
            </div>

            <div className="setting-group">
              <div className="setting-group-title">
                <span>⚙️</span>
                Account Settings
              </div>
              <div className="setting-row">
                <div className="setting-label">
                  <span>🔒</span>
                  Status
                </div>
                <div className="setting-value">
                  <span className="product-status-badge active">
                    {institution.status || 'Connected'}
                  </span>
                </div>
              </div>
              <div className="setting-row">
                <div className="setting-label">
                  <span>📊</span>
                  Data Access
                </div>
                <div className="setting-value">
                  <span className="product-status-badge active">
                    Full Access
                  </span>
                </div>
              </div>
            </div>

            <button className="action-button destructive">
              <span>🚫</span>
              Disconnect Bank
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default Institution;