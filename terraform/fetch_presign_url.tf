resource "aws_api_gateway_resource" "pre_signed_url" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "pre_signed_url"
}

resource "aws_api_gateway_method" "pre_signed_url_options" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.pre_signed_url.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "pre_signed_url_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.pre_signed_url.id
  http_method = aws_api_gateway_method.pre_signed_url_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "pre_signed_url_options_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.pre_signed_url.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [ aws_api_gateway_method.pre_signed_url_options ]
}

resource "aws_api_gateway_integration_response" "pre_signed_url_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.pre_signed_url.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_integration.pre_signed_url_options_integration
  ]
}

resource "aws_api_gateway_method" "pre_signed_url_post" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.pre_signed_url.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "pre_signed_url_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.pre_signed_url.id
  http_method             = aws_api_gateway_method.pre_signed_url_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fetch_presigned_url_handler.invoke_arn
}

resource "aws_api_gateway_method_response" "pre_signed_url_post_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.pre_signed_url.id
  http_method = "POST"
  status_code = "200"

  depends_on = [ aws_api_gateway_method.pre_signed_url_post ]
}

resource "aws_api_gateway_integration_response" "pre_signed_url_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.pre_signed_url.id
  http_method = "POST"
  status_code = "200"

  depends_on = [aws_api_gateway_integration.pre_signed_url_post_integration]
}

resource "aws_lambda_permission" "api_gateway_presigned_url" {
  statement_id  = "AllowAPIGatewayInvokePresignedURL"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_presigned_url_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.finance_api.execution_arn}/*/*/pre_signed_url"
}
