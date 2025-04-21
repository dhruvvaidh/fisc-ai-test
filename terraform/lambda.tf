
#access token handler
resource "aws_lambda_function" "access_token_handler" {
  function_name = "access_token_handler"
  filename      = "access_token.zip"  # Update with your zip location
  handler       = "access_token.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
  environment {
    variables = {
      STAGE = "prod"
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
    }
  }
}

#linked token handler
resource "aws_lambda_function" "linked_token_handler" {
  function_name = "linked_token_handler"
  filename      = "linked_token.zip"  # Update with your zip location
  handler       = "lambda_link_token.handler"
  runtime       = "python3.9"  # or nodejs18.x, etc.
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
  environment {
    variables = {
      STAGE = "prod"
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
    }
  }
}


## new update

# Create Account Handler
resource "aws_lambda_function" "get_accounts_handler" {
  function_name = "get_accounts_handler"
  filename      = "create_account.zip"  # Update with the location of your deployment package
  handler       = "create_accounts_lambda.lambda_handler"  # Update with your handler function
  runtime       = "python3.9"  # Update with your preferred runtime
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30

  environment {
    variables = {
      STAGE = "prod"
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
      DYNAMODB_TABLE     = aws_dynamodb_table.accounts.name  # Example DynamoDB table for storing accounts
    }
  }
  
}

# transaction handler
resource "aws_lambda_function" "transaction_handler" {
  function_name = "transaction_handle"
  //role          = aws_iam_role.fetch_transaction_lambda_role.arn
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.9"
  timeout       = 30
  handler       = "create_transactions.lambda_handler"
  filename      = "transaction.zip"

  environment {
    variables = {
      # DYNAMODB_TABLE     = aws_dynamodb_table.transactions.name
      # TRANSACTIONS_TABLE = aws_dynamodb_table.transactions.name
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
    }
  }
  depends_on = [
    aws_iam_role.lambda_exec,
    aws_iam_policy_attachment.lambda_execution,
    aws_iam_policy_attachment.lambda_dynamodb_full_access,
    aws_iam_role_policy_attachment.lex_runtime_access
  ]  
}

# Fetch Transactions Lambda
resource "aws_lambda_function" "fetch_transactions_handler" {
  function_name = "fetch_transactions_handler"
  filename      = "fetch_transactions.zip"  # Ensure this is the zipped deployment package
  handler       = "fetch_transactions.lambda_handler"  # Update with the handler function in your script
  runtime       = "python3.9"
  role          = aws_iam_role.fetch_transaction_lambda_role.arn
  #role          = aws_iam_role.lambda_exec.arn
  
  timeout       = 30

  environment {
    variables = {
      STAGE = "prod"
      # DYNAMODB_TABLE = aws_dynamodb_table.transactions.name
    }
  }
  depends_on = [
    aws_iam_policy_attachment.lambda_dynamodb_full_access
  ]
}


# Textract Receipt Lambda
resource "aws_lambda_function" "textract_receipt_handler" {
  function_name = "textract_receipt_handler"
  filename      = "textract.zip"
  handler       = "textract_receipt.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.textract_lambda_role.arn  
  timeout       = 30

  environment {
    variables = {
      STAGE     = "prod"
      S3_BUCKET = aws_s3_bucket.receipt_bucket.bucket
      # TRANSACTIONS_TABLE = aws_dynamodb_table.transactions.name
    }
  }
}


# Fetch Presigned URL Lambda
resource "aws_lambda_function" "fetch_presigned_url_handler" {
  function_name = "fetch_presigned_url_handler"
  filename      = "fetch_presigned_url.zip"  
  handler       = "fetch_presigned_url.lambda_handler"  
  runtime       = "python3.9"
  role          = aws_iam_role.presign_transaction_lambda_role.arn
  timeout       = 30

  environment {
    variables = {
      STAGE = "prod"
      S3_BUCKET = aws_s3_bucket.receipt_bucket.bucket  
    }
  }
  depends_on = [
    aws_iam_role.presign_transaction_lambda_role,
    aws_iam_role_policy_attachment.presign_transaction_lambda_s3_full_access,
    aws_iam_role_policy_attachment.presign_transaction_lambda_logging
  ]
 
}



# Lambda Role for access token, create account, linked token, transaction, query lex
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Lambda Policy
resource "aws_iam_policy_attachment" "lambda_execution" {
  name       = "lambda_execution_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_dynamodb_full_access" {
  name       = "lambda_dynamodb_full_access_policy"
  roles      = [
    aws_iam_role.lambda_exec.name,
    aws_iam_role.textract_lambda_role.name,
    aws_iam_role.fetch_transaction_lambda_role.name,
    aws_iam_role.query_lex_lambda_role.name
  ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lex_runtime_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonLexFullAccess"
}




# IAM Role for presign_transaction_lambda
resource "aws_iam_role" "presign_transaction_lambda_role" {
  name = "presign_transaction_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach full S3 access
resource "aws_iam_role_policy_attachment" "presign_transaction_lambda_s3_full_access" {
  role       = aws_iam_role.presign_transaction_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  
}

# Attach basic logging access
resource "aws_iam_role_policy_attachment" "presign_transaction_lambda_logging" {
  role       = aws_iam_role.presign_transaction_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  
}


# IAM Role for textract_lambda
resource "aws_iam_role" "textract_lambda_role" {
  name = "textract_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach managed policies to textract_lambda_role
resource "aws_iam_role_policy_attachment" "textract_lambda_s3" {
  role       = aws_iam_role.textract_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  depends_on = [aws_iam_role.textract_lambda_role]
}

resource "aws_iam_role_policy_attachment" "textract_lambda_bedrock" {
  role       = aws_iam_role.textract_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
  depends_on = [aws_iam_role.textract_lambda_role]
}

resource "aws_iam_role_policy_attachment" "textract_lambda_textract" {
  role       = aws_iam_role.textract_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonTextractFullAccess"
  depends_on = [aws_iam_role.textract_lambda_role]
}
resource "aws_iam_role_policy_attachment" "textract_lambda_logs" {
  role       = aws_iam_role.textract_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  depends_on = [aws_iam_role.textract_lambda_role]
}




#IAM Role for fetch_transaction_lambda
resource "aws_iam_role" "fetch_transaction_lambda_role" {
  name = "fetch_transaction_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# # Attach full DynamoDB access
# resource "aws_iam_role_policy_attachment" "fetch_transaction_lambda_dynamodb_full_access" {
#   role       = aws_iam_role.fetch_transaction_lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
# }

