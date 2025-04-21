
# API Gateway Setup
resource "aws_api_gateway_rest_api" "finance_api" {
  name        = "FinanceAPI"
  description = "API Gateway for Financial Transactions"
}
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id

  triggers = {
    redeploy = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    #transaction post and options integration
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.transactions_options_integration, 
    #linked token post and options integration
    aws_api_gateway_integration.linked_token_lambda_integration, 
    aws_api_gateway_integration.linked_token_options_integration,
    #access token post and options integration
    aws_api_gateway_integration.access_token_lambda_integration,
    aws_api_gateway_integration.access_token_options_integration,
    #get accounts post and options integration
    aws_api_gateway_integration.get_accounts_get_integration,
    aws_api_gateway_integration.get_accounts_post_integration,
    aws_api_gateway_integration.get_accounts_options_integration,
    #fetch transactions post and options integration 
    aws_api_gateway_integration.fetch_transactions_options_integration,
    aws_api_gateway_integration.fetch_transactions_get_integration,
    # Textract post and options integration
    aws_api_gateway_integration.textract_receipt_options_integration,
    aws_api_gateway_integration.textract_receipt_post_integration,
    # Presigned URL
    aws_api_gateway_integration.pre_signed_url_options_integration,
    aws_api_gateway_integration.pre_signed_url_post_integration,
    # query lex
    aws_api_gateway_integration_response.query_lex_post_integration_response,
    aws_api_gateway_integration_response.query_lex_options_integration_response
  ]
}

# transaction resource
resource "aws_api_gateway_resource" "transactions" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "create_transaction"
}

resource "aws_api_gateway_method" "transactions_post" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.transactions.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "prod"  
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.transactions.id
  http_method             = aws_api_gateway_method.transactions_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"  #proxy
  uri                     = aws_lambda_function.transaction_handler.invoke_arn
}

resource "aws_api_gateway_method_response" "transactions_post_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.transactions.id
  http_method = aws_api_gateway_method.transactions_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  # depends_on = [
  #   aws_api_gateway_method.transactions_post
  # ]
}

resource "aws_api_gateway_integration_response" "transactions_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.transactions.id
  http_method = aws_api_gateway_method.transactions_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'" # Allow all origins or specify your frontend URL
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method_response.transactions_post_response
  ]
}

resource "aws_api_gateway_method" "transactions_options" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.transactions.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "transactions_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.transactions.id
  http_method             = aws_api_gateway_method.transactions_options.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "transactions_options_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.transactions.id
  http_method = aws_api_gateway_method.transactions_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [
    aws_api_gateway_method.transactions_options
  ]

}

resource "aws_api_gateway_integration_response" "transactions_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.transactions.id
  http_method = aws_api_gateway_method.transactions_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.transactions_options_integration,
    aws_api_gateway_method_response.transactions_options_response
  ]
}


resource "random_id" "transaction_apigw_suffix" {
  byte_length = 4
}
resource "aws_lambda_permission" "transaction_apigw_permission" {
  statement_id  = "AllowAPIGatewayInvokeTransaction-${random_id.transaction_apigw_suffix.hex}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transaction_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.finance_api.execution_arn}/*/*"

  depends_on = [
    aws_lambda_function.transaction_handler,
    aws_api_gateway_rest_api.finance_api
  ]
}

#linked_token resource
resource "aws_api_gateway_resource" "linked_token" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "create_link_token"
}

resource "aws_api_gateway_method" "linked_token_post" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.linked_token.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "linked_token_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.linked_token.id
  http_method             = aws_api_gateway_method.linked_token_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"  #proxy
  uri                     = aws_lambda_function.linked_token_handler.invoke_arn
}

resource "aws_api_gateway_integration_response" "linked_token_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.linked_token.id
  http_method = aws_api_gateway_method.linked_token_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'" # Added this line
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.linked_token_lambda_integration,
    aws_api_gateway_method_response.linked_token_post_response
  ]
}

resource "aws_api_gateway_method_response" "linked_token_post_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.linked_token.id
  http_method = aws_api_gateway_method.linked_token_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [
    aws_api_gateway_method.linked_token_post
  ]
}


resource "aws_lambda_permission" "linked_token_apigw" {
  statement_id  = "AllowAPIGatewayInvokeLinkedToken"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.linked_token_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.finance_api.execution_arn}/*/*"
}

#option method
resource "aws_api_gateway_method" "linked_token_options" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.linked_token.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  depends_on = [
    aws_api_gateway_method.linked_token_options
  ]
}

resource "aws_api_gateway_integration" "linked_token_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.linked_token.id
  http_method             = aws_api_gateway_method.linked_token_options.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "linked_token_options_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.linked_token.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [
  aws_api_gateway_method.linked_token_options
] 
}

resource "aws_api_gateway_integration_response" "linked_token_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.linked_token.id
  http_method = aws_api_gateway_method.linked_token_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_integration.linked_token_options_integration,
    aws_api_gateway_method_response.linked_token_options_response  # <- critical!
  ]  
  
}


#access token resource
resource "aws_api_gateway_resource" "access_token" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "create_public_token"
}

resource "aws_api_gateway_method" "access_token_post" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.access_token.id
  http_method   = "POST"
  authorization = "NONE"

}

resource "aws_api_gateway_method_response" "access_token_post_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.access_token.id
  http_method = aws_api_gateway_method.access_token_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [
    aws_api_gateway_method.access_token_post
  ]
}
# access_token lambda integration
resource "aws_api_gateway_integration" "access_token_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.access_token.id
  http_method             = aws_api_gateway_method.access_token_post.http_method
  integration_http_method = "POST"
  type                    = "AWS" #proxy
  uri                     = aws_lambda_function.access_token_handler.invoke_arn

}

resource "aws_api_gateway_integration_response" "access_token_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.access_token.id
  http_method = aws_api_gateway_method.access_token_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'" # Allow all origins or specify your frontend URL
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.access_token_lambda_integration,
    aws_api_gateway_method_response.access_token_post_response
  ]
}

resource "aws_lambda_permission" "access_token_apigw" {
  statement_id  = "AllowAPIGatewayInvokeAccessToken"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.access_token_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.finance_api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "access_token_options" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.access_token.id
  http_method   = "OPTIONS"
  authorization = "NONE"
#   depends_on = [aws_api_gateway_method.access_token_options]
}

resource "aws_api_gateway_integration" "access_token_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.access_token.id
  http_method             = aws_api_gateway_method.access_token_options.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "access_token_options_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.access_token.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [
  aws_api_gateway_integration.access_token_options_integration
  # aws_api_gateway_method_response.access_token_options_response
  ]
}


resource "aws_api_gateway_integration_response" "access_token_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.access_token.id
  http_method = aws_api_gateway_method.access_token_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
  depends_on = [
  aws_api_gateway_integration.access_token_options_integration,
  aws_api_gateway_method_response.access_token_options_response
  ]
  
}


# get accounts API

# Define the /get_accounts resource
resource "aws_api_gateway_resource" "get_accounts" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "get_accounts"
}

# GET method for /get_accounts
resource "aws_api_gateway_method" "get_accounts_get" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.get_accounts.id
  http_method   = "GET"
  authorization = "NONE"


  request_parameters = {
    "method.request.querystring.access_token" = true
    "method.request.querystring.user_id"      = true
  }
}

resource "aws_api_gateway_integration" "get_accounts_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.get_accounts.id
  http_method             = aws_api_gateway_method.get_accounts_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_accounts_handler.invoke_arn

  request_parameters = {
  "integration.request.querystring.access_token" = "method.request.querystring.access_token"
  "integration.request.querystring.user_id"      = "method.request.querystring.user_id"
  }
}

resource "aws_api_gateway_method_response" "get_accounts_get_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.get_accounts.id
  http_method = aws_api_gateway_method.get_accounts_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "get_accounts_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.get_accounts.id
  http_method = aws_api_gateway_method.get_accounts_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.get_accounts_get_integration
  ]
}

# POST method for /get_accounts
resource "aws_api_gateway_method" "get_accounts_post" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.get_accounts.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.access_token" = true
    "method.request.querystring.user_id"      = true
  }
}

resource "aws_api_gateway_integration" "get_accounts_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.get_accounts.id
  http_method             = aws_api_gateway_method.get_accounts_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_accounts_handler.invoke_arn

  request_parameters = {
  "integration.request.querystring.access_token" = "method.request.querystring.access_token"
  "integration.request.querystring.user_id"      = "method.request.querystring.user_id"
  }
}

resource "aws_api_gateway_method_response" "get_accounts_post_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.get_accounts.id
  http_method = aws_api_gateway_method.get_accounts_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_integration_response" "get_accounts_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.get_accounts.id
  http_method = aws_api_gateway_method.get_accounts_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.get_accounts_post_integration
  ]
}

# OPTIONS method for /get_accounts
resource "aws_api_gateway_method" "get_accounts_options" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.get_accounts.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.access_token" = true
    "method.request.querystring.user_id"      = true
  }
}

resource "aws_api_gateway_integration" "get_accounts_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.get_accounts.id
  http_method             = aws_api_gateway_method.get_accounts_options.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  request_parameters = {
  "integration.request.querystring.access_token" = "method.request.querystring.access_token"
  "integration.request.querystring.user_id"      = "method.request.querystring.user_id"
  }
}

resource "aws_api_gateway_method_response" "get_accounts_options_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.get_accounts.id
  http_method = aws_api_gateway_method.get_accounts_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "get_accounts_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.get_accounts.id
  http_method = aws_api_gateway_method.get_accounts_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.get_accounts_options_integration,
    aws_api_gateway_method_response.get_accounts_options_response
  ]
}

resource "aws_lambda_permission" "get_accounts_apigw" {
  statement_id  = "AllowAPIGatewayInvokeGetAccounts"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_accounts_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.finance_api.execution_arn}/*/*"

}


