import os
import json
import plaid
from plaid.api.plaid_api import PlaidApi
from plaid.model.sandbox_public_token_create_request import SandboxPublicTokenCreateRequest
from plaid.model.item_public_token_exchange_request import ItemPublicTokenExchangeRequest
from plaid.model.transactions_get_request import TransactionsGetRequest
from plaid.model.transactions_get_request_options import TransactionsGetRequestOptions
from plaid.model.products import Products
from plaid.configuration import Configuration
from plaid.api_client import ApiClient
from datetime import datetime, timedelta

# Plaid API credentials
PLAID_CLIENT_ID = os.environ['PLAID_CLIENT_ID']
PLAID_SECRET = os.environ['PLAID_SECRET']
PLAID_ENV = os.environ['PLAID_ENVIRONMENT']
# Plaid environment configuration
configuration = Configuration(
    host="https://sandbox.plaid.com",  # Use "https://production.plaid.com" for production
    api_key={
        'clientId': PLAID_CLIENT_ID,
        'secret': PLAID_SECRET,
    }
)
api_client = ApiClient(configuration)
client = PlaidApi(api_client)

def lambda_handler(event, context):
    try:
        # Step 1: Create a sandbox public token
        sandbox_request = SandboxPublicTokenCreateRequest(
            institution_id="ins_109508",  # Sandbox institution ID (e.g., Chase)
            initial_products=[Products("transactions")],  # Specify the product(s)
        )
        sandbox_response = client.sandbox_public_token_create(sandbox_request)
        public_token = sandbox_response['public_token']

        # Step 2: Exchange the public token for an access token
        exchange_request = ItemPublicTokenExchangeRequest(public_token=public_token)
        exchange_response = client.item_public_token_exchange(exchange_request)
        access_token = exchange_response['access_token']

        # Step 3: Fetch transactions using the access token
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=30)  # Fetch transactions for the last 30 days

        # transactions_response = client.transactions_get(transactions_request)
        # transactions = transactions_response['transactions']

        # Step 4: Return the transactions in the response
        return {
            'statusCode': 200,
            'body': json.dumps({
                # 'transactions': [transaction.to_dict() for transaction in transactions]
                'acess_token': access_token
            })
        }
    except Exception as e:
        # Handle exceptions and return an error response
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }
