# Define the /query_lex resource
resource "aws_api_gateway_resource" "query_lex" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "query_lex"
}

# POST method for /query_lex
resource "aws_api_gateway_method" "query_lex_post" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.query_lex.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "query_lex_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.query_lex.id
  http_method             = aws_api_gateway_method.query_lex_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.query_lex_handler.invoke_arn
}

resource "aws_api_gateway_method_response" "query_lex_post_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.query_lex.id
  http_method = aws_api_gateway_method.query_lex_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [ aws_api_gateway_method.query_lex_post ]
}

resource "aws_api_gateway_integration_response" "query_lex_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.query_lex.id
  http_method = aws_api_gateway_method.query_lex_post.http_method
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
    aws_api_gateway_integration.query_lex_post_integration,
    aws_api_gateway_method_response.query_lex_post_response
  ]
}

# OPTIONS method for /query_lex
resource "aws_api_gateway_method" "query_lex_options" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.query_lex.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "query_lex_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.query_lex.id
  http_method             = aws_api_gateway_method.query_lex_options.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "query_lex_options_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.query_lex.id
  http_method = aws_api_gateway_method.query_lex_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [ aws_api_gateway_method.query_lex_options ]
}

resource "aws_api_gateway_integration_response" "query_lex_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.query_lex.id
  http_method = aws_api_gateway_method.query_lex_options.http_method
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
    aws_api_gateway_integration.query_lex_options_integration,
    aws_api_gateway_method_response.query_lex_options_response
  ]
}




