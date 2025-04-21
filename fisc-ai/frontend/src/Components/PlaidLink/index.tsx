import React from 'react';
import { usePlaidLink } from "react-plaid-link";


interface PlaidLinkProps {
  linkToken: string;
  setAccessToken: (token: string) => void;
  API_BASE_URL: string;
  setPublicToken?: (token: string) => void;
}

const PlaidLink = ({ linkToken, setAccessToken, API_BASE_URL, setPublicToken }: PlaidLinkProps) => {
  const onSuccess = async (publicToken: string, metadata: any) => {
    console.log("Public Token:", publicToken);
    console.log("Metadata:", metadata);
    
    if (setPublicToken) {
      setPublicToken(publicToken);
    }
    
    try {
      const response = await fetch(`${API_BASE_URL}/create_public_token`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ public_token: publicToken })
      });

      if (!response.ok) {
        throw new Error('Failed to exchange token');
      }

      

      const data = await response.json();
      const parsedData = JSON.parse(data.body);
      if (parsedData.access_token) {
        console.log('Access token received:', parsedData.access_token);
        localStorage.setItem("access_token", parsedData.access_token);
        setAccessToken(parsedData.access_token);
      }
    } catch (error) {
      console.error('Error exchanging public token:', error);
    }
  };

  const config = {
    token: linkToken,
    onSuccess,
  };

  const { open, ready } = usePlaidLink(config);

  return (
    <button 
      onClick={() => open()} 
      disabled={!ready}
      style={{ 
        padding: '10px 20px',
        backgroundColor: ready ? '#4CAF50' : '#cccccc',
        color: 'white',
        border: 'none',
        borderRadius: '4px',
        cursor: ready ? 'pointer' : 'not-allowed'
      }}
    >
      {ready ? 'Connect a bank account' : 'Loading...'}
    </button>
  );
};

export default PlaidLink; 