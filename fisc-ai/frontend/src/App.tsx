import React, { useEffect, useContext, useCallback, useState } from "react";
import { signOut as amplifySignOut } from '@aws-amplify/auth';
import { motion, AnimatePresence } from 'framer-motion';

import Header from "./Components/Headers";
import Products from "./Components/ProductTypes/Products";
import Items from "./Components/ProductTypes/Items";
import Context from "./Context";
import Sidebar from './Components/Sidebar';
import ChatWidget from './Components/ChatWidget';
import Institutions from './Components/Institutions';
import Transactions from './Components/Transactions';
import Dashboard from './views/Dashboard';
import Analytics from './Components/Analytics';

import { CraCheckReportProduct } from "plaid";
import { Amplify } from 'aws-amplify';
import awsconfig from './aws-exports';
import type { WithAuthenticatorProps } from '@aws-amplify/ui-react';
import { withAuthenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import './App.css';
import { usePlaidLink } from "react-plaid-link";
import LoadingScreen from './Components/LoadingScreen';
import FiscAILogo from './assets/FiscAI.jpeg';
Amplify.configure(awsconfig);
export const API_BASE_URL = "REPLACE_WITH_API_GW_BASE_URL";

const App = ({ signOut, user }: WithAuthenticatorProps) => {
  const { linkSuccess, isPaymentInitiation, itemId, dispatch } =
    useContext(Context);
  const [linkToken, setLinkToken] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [institutions, setInstitutions] = useState<Array<{
    institution_id: string;
    name: string;
    logo?: string | null;
    products?: string[];
    status?: string;
    accounts: any[];
  }>>([]);
  const [accessToken, setAccessToken] = useState<string | null>(null);
  const [activeView, setActiveView] = useState('dashboard');
  const [transactions, setTransactions] = useState([]);
  const [isInitialized, setIsInitialized] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [initError, setInitError] = useState<string | null>(null);

  const initializeFromPlaid = useCallback(async (token: string) => {
    try {
      console.log("🔄 Populating transactions from Plaid...");
      
      const plaidResponse = await fetch(
        `${API_BASE_URL}/create_transaction?access_token=${token}&user_id=${user?.username}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            access_token: token,
            user_id: user?.username
          })
        }
      );

      if (!plaidResponse.ok) {
        throw new Error('Failed to initialize transactions from Plaid');
      }

      console.log("✅ Successfully populated transactions table");
      setIsInitialized(true);
    } catch (error) {
      console.error("❌ Error initializing transactions:", error);
      setInitError(error instanceof Error ? error.message : 'Failed to initialize transactions');
      setIsInitialized(true);
    }
  }, [user?.username]);

  const initializeApp = useCallback(async () => {
    try {
      console.log("🚀 Initializing app...");
      setIsLoading(true);
      
      // Clear any existing tokens
      localStorage.removeItem("access_token");
      localStorage.removeItem("link_token");
      
      // Step 1: Generate new access token
      console.log("Step 1: Generating new access token...");
      const accessTokenResponse = await fetch(`${API_BASE_URL}/create_public_token`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!accessTokenResponse.ok) {
        throw new Error("Failed to generate access token");
      }

      const accessTokenData = await accessTokenResponse.json();
      const parsedAccessData = JSON.parse(accessTokenData.body);
      const newAccessToken = parsedAccessData.access_token || parsedAccessData.acess_token;
      
      if (!newAccessToken) {
        throw new Error("Failed to get valid access token");
      }
      
      // Set access token immediately so it's available for other operations
      setAccessToken(newAccessToken);
      localStorage.setItem("access_token", newAccessToken);

      // Step 2: Initialize Plaid transactions with the new access token
      console.log("Step 2: Initializing Plaid transactions...");
      await initializeFromPlaid(newAccessToken);

      // Step 3: Generate new link token
      console.log("Step 3: Generating new link token...");
      const linkTokenResponse = await fetch(`${API_BASE_URL}/create_link_token`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!linkTokenResponse.ok) {
        const errorText = await linkTokenResponse.text();
        console.error("Link token error:", errorText);
        throw new Error(`Failed to generate link token: ${errorText}`);
      }

      const linkTokenData = await linkTokenResponse.json();
      const parsedLinkData = JSON.parse(linkTokenData.body);
      const newLinkToken = parsedLinkData.link_token;
      
      if (!newLinkToken) {
        throw new Error("Failed to get valid link token");
      }

      setLinkToken(newLinkToken);
      localStorage.setItem("link_token", newLinkToken);

      // Step 4: Fetch accounts with the access token
      console.log("Step 4: Fetching accounts...");
      const getAccountsResponse = await fetch(
        `${API_BASE_URL}/get_accounts?access_token=${newAccessToken}&user_id=${user?.username}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({})
        }
      );

      if (!getAccountsResponse.ok) {
        throw new Error("Failed to fetch accounts");
      }

      const accountsData = await getAccountsResponse.json();
      
      // Process institutions data
      const institutionsMap = new Map();
      accountsData.accounts.accounts.forEach((account: any) => {
        const institutionId = account.institution_id || accountsData.accounts.item.institution_id;
        const institutionName = account.institution_name || accountsData.accounts.item.institution_name;
        
        if (!institutionsMap.has(institutionId)) {
          institutionsMap.set(institutionId, {
            institution_id: institutionId,
            name: institutionName,
            logo: null,
            products: account.products || accountsData.accounts.item.products || [],
            status: 'Connected',
            accounts: []
          });
        }
        institutionsMap.get(institutionId).accounts.push(account);
      });
      
      setInstitutions(Array.from(institutionsMap.values()));
      setIsInitialized(true);
      
    } catch (error) {
      console.error("Detailed error during initialization:", error);
      setError(error instanceof Error ? error.message : "An error occurred during initialization");
      setInitError(error instanceof Error ? error.message : "Failed to initialize application");
    } finally {
      setIsLoading(false);
    }
  }, [initializeFromPlaid, user?.username]);
  useEffect(() => {
    initializeApp();
  }, [initializeApp]);

  
  useEffect(() => {
    if (isInitialized) {
      setTimeout(() => setIsLoading(false), 2000);
    }
  }, [isInitialized]);

  const handleSignOut = async () => {
    try {
      await amplifySignOut();
      if (signOut) {
        signOut();
      }
    } catch (error) {
      console.error("Error signing out:", error);
    }
  };

  const renderContent = () => {
    switch (activeView) {
      case 'dashboard':
        return (
          <Dashboard 
            error={error}
            linkToken={linkToken}
            accessToken={accessToken}
            setAccessToken={setAccessToken}
            API_BASE_URL={API_BASE_URL}
          />
        );

      case 'transactions':
        return (
          <div className="view-container">
            {accessToken ? (
              <Transactions 
                accessToken={accessToken}
                API_BASE_URL={API_BASE_URL}
                userId={user?.username || ''}
              />
            ) : (
              <p>Please wait while we connect to your bank account...</p>
            )}
          </div>
        );

      case 'bank-accounts':
        return (
          <div className="view-container">
            <Institutions institutions={institutions} />
          </div>
        );

      case 'analytics':
        return (
          <div className="view-container">
            {accessToken ? (
              <Analytics 
                accessToken={accessToken}
                API_BASE_URL={API_BASE_URL}
                userId={user?.username || ''}
              />
            ) : (
              <p>Please connect your bank account to view analytics.</p>
            )}
          </div>
        );

      case 'profile':
        return (
          <div className="view-container">
            <h2>Profile</h2>
            <div className="profile-info">
              <p>Username: {user?.signInDetails?.loginId}</p>
              {/* Add more profile information */}
            </div>
          </div>
        );

      case 'settings':
        return (
          <div className="view-container">
            <h2>Settings</h2>
            {/* Add your settings component here */}
          </div>
        );

      default:
        return <div>Page not found</div>;
    }
  };

  return (
    <AnimatePresence mode="wait">
      {isLoading ? (
        <LoadingScreen />
      ) : (
        <motion.div
          key="app"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="app-container"
        >
          <Sidebar 
            activeView={activeView}
            onNavigate={setActiveView}
          />
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ 
              opacity: 1, 
              x: 0,
              transition: { 
                delay: 0.2,
                duration: 0.5
              }
            }}
            className="main-content"
          >
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ 
                opacity: 1, 
                y: 0,
                transition: { 
                  delay: 0.4,
                  duration: 0.5
                }
              }}
              className="top-header"
            >
              <div className="header-content">
                <h1>Welcome, {user?.signInDetails?.loginId}</h1>
                <button className="signin-button" onClick={handleSignOut}>
                  Sign out
                </button>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ 
                opacity: 1, 
                scale: 1,
                transition: { 
                  delay: 0.6,
                  duration: 0.5
                }
              }}
              className="dashboard-content"
            >
              {renderContent()}
            </motion.div>
          </motion.div>
          <ChatWidget />
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default withAuthenticator(App, {
  socialProviders: ['google'],
  signUpAttributes: ['email', 'name'],
  components: {
    Header() {
      return (
        <div style={{
          textAlign: 'center',
          padding: '2rem 0',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          backgroundColor: 'white'
        }}>
          <div style={{
            width: '120px',
            height: '120px',
            borderRadius: '12px',
            overflow: 'hidden',
            boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
            backgroundColor: 'white',
            padding: '8px'
          }}>
            <img 
              src={FiscAILogo} 
              alt="FiscAI Logo" 
              style={{
                width: '100%',
                height: '100%',
                objectFit: 'contain'
              }}
            />
          </div>
        </div>
      );
    },
  },
});
