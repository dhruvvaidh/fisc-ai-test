import React from 'react';
import './Sidebar.css';
import fiscaiLogo from '../../assets/FiscAI.jpeg';

interface SidebarProps {
  activeView: string;
  onNavigate: (view: string) => void;
}

const Sidebar = ({ activeView, onNavigate }: SidebarProps) => {
  return (
    <div className="sidebar">
      <div className="sidebar-header">
        <img 
          src={fiscaiLogo}
          alt="FiscAI Logo" 
          className="sidebar-logo"
        />
      </div>
      
      <nav className="sidebar-nav">
        <ul>
          <li 
            className={`nav-item ${activeView === 'dashboard' ? 'active' : ''}`}
            onClick={() => onNavigate('dashboard')}
          >
            <i className="fas fa-chart-line"></i>
            <span>Dashboard</span>
          </li>
          <li 
            className={`nav-item ${activeView === 'bank-accounts' ? 'active' : ''}`}
            onClick={() => onNavigate('bank-accounts')}
          >
            <i className="fas fa-university"></i>
            <span>Bank Accounts</span>
          </li>
          <li 
            className={`nav-item ${activeView === 'transactions' ? 'active' : ''}`}
            onClick={() => onNavigate('transactions')}
          >
            <i className="fas fa-exchange-alt"></i>
            <span>Transactions</span>
          </li>
          <li 
            className={`nav-item ${activeView === 'analytics' ? 'active' : ''}`}
            onClick={() => onNavigate('analytics')}
          >
            <i className="fas fa-chart-pie"></i>
            <span>Analytics</span>
          </li>
          <li 
            className={`nav-item ${activeView === 'profile' ? 'active' : ''}`}
            onClick={() => onNavigate('profile')}
          >
            <i className="fas fa-user-circle"></i>
            <span>Profile</span>
          </li>
          <li 
            className={`nav-item ${activeView === 'settings' ? 'active' : ''}`}
            onClick={() => onNavigate('settings')}
          >
            <i className="fas fa-cog"></i>
            <span>Settings</span>
          </li>
        </ul>
      </nav>
    </div>
  );
};

export default Sidebar;