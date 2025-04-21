import React, { useEffect, useContext, useCallback, useState } from "react";
import { signOut as amplifySignOut } from '@aws-amplify/auth';

import Header from "./Components/Headers";
import Products from "./Components/ProductTypes/Products";
import Items from "./Components/ProductTypes/Items";
import Context from "./Context";
import Sidebar from './Components/Sidebar';
import ChatWidget from './Components/ChatWidget';
import Institutions from './Components/Institutions';

import { CraCheckReportProduct } from "plaid";
import { Amplify } from 'aws-amplify';
import awsconfig from './aws-exports';
import type { WithAuthenticatorProps } from '@aws-amplify/ui-react';
import { withAuthenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import './App.css';
import { usePlaidLink } from "react-plaid-link";
Amplify.configure(awsconfig);

// const API_BASE_URL = "https://7o81y9tcsa.execute-api.us-east-1.amazonaws.com/dev";
const API_BASE_URL = "https://rf59517zr9.execute-api.us-east-1.amazonaws.com/prod";

//console.log(import.meta.env)

//const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;     //leo

//console.log("Base URL:", import.meta.env.VITE_API_BASE_URL);


const App = ({ signOut, user }: WithAuthenticatorProps) => {
  const { linkSuccess, isPaymentInitiation, itemId, dispatch } =
    useContext(Context);
  const [linkToken, setLinkToken] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [institutions, setInstitutions] = useState([]);

  // Function to generate the Link Token
  const generateLinkToken = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/linked_token`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
      });
  
      console.log("Response status:", response.status);
  
      if (!response.ok) {
        const errorText = await response.text(); // Read the response body for error logging
        console.error("Response body:", errorText);
        throw new Error("Failed to generate link token");
      }
  
      const data = await response.json(); // Parse the response body as JSON
      const parsedBody = JSON.parse(data.body);
  
      if (parsedBody.link_token) {
        setLinkToken(parsedBody.link_token); // Save the link token
        localStorage.setItem("link_token", parsedBody.link_token); // Save it for OAuth flow
      } else {
        throw new Error("Link token not found in response");
      }
    } catch (err: any) {
      console.error("Error generating link token:", err);
      setError(err.message || "An error occurred");
    }
  }, []);

  // Fetch institutions
  const fetchInstitutions = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/institutions`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!response.ok) {
        throw new Error("Failed to fetch institutions");
      }

      const data = await response.json();
      setInstitutions(data.institutions);
    } catch (error) {
      console.error("Error fetching institutions:", error);
    }
  }, []);

  // Fetch the link token when the component loads
  useEffect(() => {
    generateLinkToken();
    fetchInstitutions();
  }, [generateLinkToken, fetchInstitutions]);

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

  return (
    <div className="app-container">
      <Sidebar />
      <div className="main-content">
        <div className="top-header">
          <div className="header-content">
            <h1>Welcome, {user?.username}</h1>
            <button className="signin-button" onClick={handleSignOut}>
              Sign out
            </button>
          </div>
        </div>

        <div className="dashboard-content">
          <Header />
          {error && <p style={{ color: "red" }}>Error: {error}</p>}
          {!linkToken && <p>Loading Link UI...</p>}
          {linkToken && (
            <div>
              <p>Link Token Generated Successfully!</p>
              <PlaidLink linkToken={linkToken} />
            </div>
          )}
            <Institutions institutions={institutions} />
            <Products />
            {!isPaymentInitiation && itemId && (
            <>
              <Items />
              {/* <button onClick={simpleTransactionCall}>Get Transactions</button> */}
            </>
            )}
        </div>
      </div>
      <ChatWidget />
    </div>
  );
};

// Plaid Link Component
const PlaidLink = ({ linkToken }: { linkToken: string }) => {
  const onSuccess = (publicToken: string, metadata: any) => {
    console.log("Public Token:", publicToken);
    console.log("Metadata:", metadata);
    // Send the public token to your backend for further processing
  };

  const config = {
    token: linkToken, // The link token generated from your backend
    onSuccess, // Callback function when the user successfully links their account
  };

  const { open, ready } = usePlaidLink(config);

  return (
    <button onClick={() => open()} disabled={!ready}>
      Open Plaid Link
    </button>
  );
};

export default withAuthenticator(App);