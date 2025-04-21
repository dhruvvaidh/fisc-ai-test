resource "aws_api_gateway_resource" "textract_receipt" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "textract_receipt"
}

#options method for textract_receipt
resource "aws_api_gateway_method" "textract_receipt_options" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.textract_receipt.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "textract_receipt_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.textract_receipt.id
  http_method = aws_api_gateway_method.textract_receipt_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "textract_receipt_options_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.textract_receipt.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [ aws_api_gateway_method.textract_receipt_options ]
}

resource "aws_api_gateway_integration_response" "textract_receipt_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.textract_receipt.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_method_response.textract_receipt_options_response
  ]
}

#post method
resource "aws_api_gateway_method" "textract_receipt_post" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.textract_receipt.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "textract_receipt_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.textract_receipt.id
  http_method             = aws_api_gateway_method.textract_receipt_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.textract_receipt_handler.invoke_arn
}

resource "aws_api_gateway_method_response" "textract_receipt_post_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.textract_receipt.id
  http_method = "POST"
  status_code = "200"

  depends_on = [ aws_api_gateway_method.textract_receipt_post ]
}

resource "aws_api_gateway_integration_response" "textract_receipt_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  resource_id = aws_api_gateway_resource.textract_receipt.id
  http_method = "POST"
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.textract_receipt_post_integration,
    aws_api_gateway_method_response.textract_receipt_post_response
  ]
}


resource "aws_lambda_permission" "api_gateway_textract_receipt" {
  statement_id  = "AllowAPIGatewayInvokeTextractReceipt"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.textract_receipt_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.finance_api.execution_arn}/*/*/textract_receipt"
}
