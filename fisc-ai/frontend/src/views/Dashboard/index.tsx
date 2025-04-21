import React, { useState } from 'react';
import { Card, Heading, Flex, Text, View, Button, Badge } from '@aws-amplify/ui-react';
import PlaidLink from '../../Components/PlaidLink';

// Add interface for Dashboard props
interface DashboardProps {
  error: string | null;
  linkToken: string | null;
  accessToken: string | null;
  setAccessToken: (token: string) => void;
  API_BASE_URL: string;  // Add this prop
}

const Dashboard = ({ 
  error, 
  linkToken, 
  accessToken, 
  setAccessToken,
  API_BASE_URL  // Add this prop
}: DashboardProps) => {
  const [publicToken, setPublicToken] = useState<string | null>(null);

  return (
    <View padding="20px">
      <Card variation="elevated">
        <Heading level={1} padding="20px">
          Welcome to FiscAI
        </Heading>
        


        {/* Plaid Connection Section */}
        <Card variation="outlined" padding="20px" marginBottom="20px">
          <Heading level={3} marginBottom="15px">
            Connect Your Bank Account
          </Heading>
          
          {!linkToken ? (
            <Flex direction="column" alignItems="center" padding="20px">
              <Text variation="warning">Loading Plaid Link...</Text>
              {/* Add a loading spinner here */}
            </Flex>
          ) : (
            <Flex direction="column" gap="15px">
              <Text>
                Securely connect your bank account to start tracking your transactions
                and managing your finances with AI-powered insights.
              </Text>
              <PlaidLink 
                linkToken={linkToken} 
                setAccessToken={setAccessToken}
                API_BASE_URL={API_BASE_URL}
                setPublicToken={setPublicToken}
              />
            </Flex>
          )}
        </Card>

        {/* Features Preview */}
        <Flex direction="row" gap="20px" wrap="wrap">
          <Card variation="outlined" padding="20px" flex="1" minWidth="250px">
            <Heading level={4}>Transaction Analysis</Heading>
            <Text>
              View and analyze your transactions with AI-powered categorization
              and insights.
            </Text>
          </Card>

          <Card variation="outlined" padding="20px" flex="1" minWidth="250px">
            <Heading level={4}>Receipt Processing</Heading>
            <Text>
              Upload receipts for automatic data extraction and transaction
              matching.
            </Text>
          </Card>

          <Card variation="outlined" padding="20px" flex="1" minWidth="250px">
            <Heading level={4}>AI Assistant</Heading>
            <Text>
              Get personalized financial insights and answers to your questions.
            </Text>
          </Card>
        </Flex>

        {/* Debug Information (Collapsible) */}
        {/* Commenting out access token details for security
        {(publicToken || accessToken) && ( */}
        {(publicToken) && (
          <Card 
            variation="outlined" 
            padding="20px" 
            marginTop="20px"
            backgroundColor="#f8f9fa"
          >
            <Heading level={4}>Connection Details</Heading>
            
            {publicToken && (
              <View 
                padding="10px" 
                backgroundColor="#e6f7ff"
                borderRadius="4px"
                marginBottom="10px"
              >
                <Text fontWeight="bold">🔑 Public Token</Text>
                <Text 
                  fontSize="sm"
                  style={{ wordBreak: 'break-all' }}
                  padding="10px"
                  backgroundColor="white"
                  borderRadius="4px"
                >
                  {publicToken}
                </Text>
              </View>
            )}
            
            {accessToken && (
              <View 
                padding="10px" 
                backgroundColor="#e6ffe6"
                borderRadius="4px"
              >
                <Text fontWeight="bold">🔐 Access Token</Text>
                <Text 
                  fontSize="sm"
                  style={{ wordBreak: 'break-all' }}
                  padding="10px"
                  backgroundColor="white"
                  borderRadius="4px"
                >
                  {accessToken}
                </Text>
              </View>
            )}
          </Card>
        )}
      </Card>
    </View>
  );
};

export default Dashboard; 