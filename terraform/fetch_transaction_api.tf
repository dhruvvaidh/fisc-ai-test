resource "aws_api_gateway_resource" "fetch_transactions_dynamo" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "fetch_transactions_dynamo"
}

resource "aws_api_gateway_method" "fetch_transactions_options" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.fetch_transactions_dynamo.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "fetch_transactions_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.fetch_transactions_dynamo.id
  http_method = aws_api_gateway_method.fetch_transactions_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "fetch_transactions_options_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.fetch_transactions_dynamo.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [ aws_api_gateway_method.fetch_transactions_options ] 
}

resource "aws_api_gateway_integration_response" "fetch_transactions_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.fetch_transactions_dynamo.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_method_response.fetch_transactions_options_response,
    aws_api_gateway_integration.fetch_transactions_options_integration
  ]

}

resource "aws_api_gateway_method" "fetch_transactions_get" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.fetch_transactions_dynamo.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "fetch_transactions_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.fetch_transactions_dynamo.id
  http_method             = aws_api_gateway_method.fetch_transactions_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fetch_transactions_handler.invoke_arn
}

resource "aws_api_gateway_method_response" "fetch_transactions_get_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.fetch_transactions_dynamo.id
  http_method = "GET"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Cridentials" = true
  }
  depends_on = [ aws_api_gateway_method.fetch_transactions_get ]
}

resource "aws_api_gateway_integration_response" "fetch_transactions_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.fetch_transactions_dynamo.id
  http_method = "GET"
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.fetch_transactions_get_integration,
    aws_api_gateway_method_response.fetch_transactions_get_response
    ]
}

resource "aws_lambda_permission" "api_gateway_fetch_transactions" {
  statement_id  = "AllowAPIGatewayInvokeFetchTransactions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_transactions_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.finance_api.execution_arn}/*/*/fetch_transactions_dynamo"
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_lambda_function.fetch_transactions_handler,
    aws_api_gateway_rest_api.finance_api,
    aws_api_gateway_resource.fetch_transactions_dynamo,
    aws_api_gateway_method.fetch_transactions_get,
    aws_api_gateway_integration.fetch_transactions_get_integration,
    aws_api_gateway_integration_response.fetch_transactions_get_integration_response,
  ]

}
