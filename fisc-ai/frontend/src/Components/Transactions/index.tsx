import React, { useEffect, useState, useCallback } from 'react';
import { Table, TableHead, TableRow, TableCell, TableBody } from '@aws-amplify/ui-react';
import UploadModal from './UploadModal';
import styles from './Transactions.module.css';

interface Transaction {
  category_id: string;
  pending: boolean;
  account_owner: string | null;
  transaction_id: string;
  iso_currency_code: string;
  date: string;
  name?: string;
  merchant_name?: string;
  amount: number;
  logo_url?: string | null;
  personal_finance_category?: {
    primary: string;
    detailed?: string;
    confidence_level?: string;
  };
}



interface TransactionsProps {
  accessToken: string;
  API_BASE_URL: string;
  userId: string;
}

const Transactions = ({ accessToken, API_BASE_URL, userId }: TransactionsProps) => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isUploadModalOpen, setIsUploadModalOpen] = useState(false);
  const [uploadStatus, setUploadStatus] = useState('');
  const [lastFetchTime, setLastFetchTime] = useState<number | null>(null);

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    date.setDate(date.getDate() + 1); // Add one day
    return date.toLocaleDateString('en-US', { 
      month: 'short', 
      day: '2-digit', 
      year: 'numeric' 
    });
  };

  const shouldFetchData = useCallback(() => {
    if (!lastFetchTime) return true;
    const fiveMinutes = 5 * 60 * 1000;
    return Date.now() - lastFetchTime > fiveMinutes;
  }, [lastFetchTime]);

  const fetchTransactions = useCallback(async () => {
    if (transactions.length > 0 && !shouldFetchData()) {
      console.log("Using cached transactions data");
      return;
    }

    try {
      setIsLoading(true);
      console.log("🔄 Fetching transactions from DynamoDB...");

      const dynamoResponse = await fetch(
        `${API_BASE_URL}/fetch_transactions_dynamo`,
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          }
        }
      );

      if (!dynamoResponse.ok) {
        const errorData = await dynamoResponse.json();
        console.error("❌ Transaction fetch error:", errorData);
        throw new Error(`Failed to fetch transactions: ${errorData.error || dynamoResponse.statusText}`);
      }

      const dynamoData = await dynamoResponse.json();
      console.log("✅ Raw transactions data:", dynamoData);
      console.log("Total transactions in response:", dynamoData.transactions?.length);
      
      if (dynamoData.transactions) {
        try {
          // Validate required fields
          dynamoData.transactions.forEach((t: any, index: number) => {
            const missingFields = [];
            if (!t.date) missingFields.push('date');
            if (!t.transaction_id) missingFields.push('transaction_id');
            if (t.amount === undefined) missingFields.push('amount');
            if (missingFields.length > 0) {
              console.warn(`Transaction at index ${index} is missing required fields:`, missingFields, t);
            }
          });

          // Process transactions to ensure consistent format
          const processedTransactions = dynamoData.transactions.map((t: any) => ({
            ...t,
            // Ensure logo_url is either a valid URL or null
            logo_url: t.logo_url && t.logo_url.startsWith('http') ? t.logo_url : null,
            // Ensure personal_finance_category has the correct structure
            personal_finance_category: t.personal_finance_category || {
              primary: 'MISC',
              detailed: 'Miscellaneous',
              confidence_level: 'LOW'
            }
          }));

          const sortedTransactions = processedTransactions.sort((a: any, b: any) => {
            try {
              return new Date(b.date).getTime() - new Date(a.date).getTime();
            } catch (error) {
              console.error("Error sorting transaction:", { a, b, error });
              return 0;
            }
          });

          console.log("Transactions before sorting:", dynamoData.transactions.length);
          console.log("Transactions after sorting:", sortedTransactions.length);

          setTransactions(sortedTransactions);
          setLastFetchTime(Date.now());
        } catch (error) {
          console.error("Error processing transactions:", error);
          setTransactions(dynamoData.transactions);
        }
      } else {
        console.error("❌ Unexpected response structure:", dynamoData);
        throw new Error("Invalid response format from server");
      }
    } catch (error) {
      console.error("❌ Error fetching transactions:", error);
      setError(error instanceof Error ? error.message : "Failed to fetch transactions");
    } finally {
      setIsLoading(false);
    }
  }, [API_BASE_URL, shouldFetchData]);

  useEffect(() => {
    if (API_BASE_URL) {
      fetchTransactions();
    }
  }, [API_BASE_URL, fetchTransactions]);

  const handleReceiptUpload = async (file: File) => {
    try {
      setUploadStatus('Getting upload URL...');
      
      // Step 1: Get pre-signed URL
      const presignedUrlResponse = await fetch(`${API_BASE_URL}/pre_signed_url`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          fileName: file.name,
          fileType: file.type
        })
      });

      if (!presignedUrlResponse.ok) {
        throw new Error('Failed to get upload URL');
      }

      const { uploadUrl } = await presignedUrlResponse.json();
      console.log("Got pre-signed URL:", uploadUrl);

      // Step 2: Upload to S3 using the pre-signed URL
      setUploadStatus('Uploading to S3...');
      const uploadResponse = await fetch(uploadUrl, {
        method: 'PUT',
        body: file,
        headers: {
          'Content-Type': file.type
        }
      });

      if (!uploadResponse.ok) {
        throw new Error('Failed to upload to S3');
      }

      console.log("File uploaded to S3 successfully");
      setUploadStatus('Processing receipt...');

      // Step 3: Trigger Textract processing
      const processResponse = await fetch(`${API_BASE_URL}/textract_receipt`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          fileName: file.name
        })
      });

      if (!processResponse.ok) {
        throw new Error('Failed to process receipt');
      }

      setUploadStatus('Receipt uploaded and processed successfully!');
      setTimeout(() => {
        setIsUploadModalOpen(false);
        setUploadStatus('');
      }, 2000);

    } catch (error) {
      console.error('Upload error:', error);
      setUploadStatus('Failed to upload receipt');
    }
  };

  const handleRefresh = () => {
    setLastFetchTime(null);
    fetchTransactions();
  };

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
            <span className={`${styles['button-icon']} ${isLoading ? styles.spinning : ''}`}>
              ↻
            </span>
            <span>Refresh</span>
          </button>
          <button 
            onClick={() => setIsUploadModalOpen(true)}
            className={`${styles['action-button']} ${styles['primary']}`}
          >
            <span className={styles['button-icon']}>↑</span>
            <span>Upload Receipt</span>
          </button>
        </div>
      </div>

      {isLoading ? (
        <p>Loading transactions...</p>
      ) : error ? (
        <p className="error-message">{error}</p>
      ) : (
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
            {transactions.map((transaction) => (
              <TableRow key={transaction.transaction_id}>
                <TableCell>{formatDate(transaction.date)}</TableCell>
                <TableCell>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    {transaction.logo_url ? (
                      <img
                        src={transaction.logo_url}
                        alt={transaction.merchant_name || transaction.name}
                        style={{ width: '24px', height: '24px', borderRadius: '50%' }}
                      />
                    ) : (
                      <span style={{ fontSize: '20px' }}>💵</span>
                    )}
                    {transaction.merchant_name || transaction.name || 'Unknown'}
                  </div>
                </TableCell>
                <TableCell>
                  {transaction.personal_finance_category?.primary || 'MISC'}
                </TableCell>
                <TableCell style={{ color: transaction.amount < 0 ? '#d32f2f' : '#2e7d32' }}>
                  {formatAmount(transaction.amount)}
                </TableCell>
                <TableCell>{transaction.pending ? 'Pending' : 'Completed'}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}

      <UploadModal
        isOpen={isUploadModalOpen}
        onClose={() => {
          setIsUploadModalOpen(false);
          setUploadStatus('');
        }}
        onUpload={handleReceiptUpload}
        uploadStatus={uploadStatus}
      />
    </div>
  );
};

export default Transactions; 