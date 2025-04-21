output "amplify_app_url" {
  value = "https://${aws_amplify_branch.main_branch.branch_name}.${aws_amplify_app.plaid_app.default_domain}"
  description = "URL to access the deployed Amplify app"
}

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.finance_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}"
  description = "URL to access the deployed API Gateway"
}

output "s3_bucket" {
  value = aws_s3_bucket.receipt_bucket.id
}

# AWS lex needs
output "apigw_arn" {
  value = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.finance_api.id}/prod/POST/query_lex"
}

output "resolved_lex_alias_id" {
  value = data.external.lex_alias_id.result.lex_bot_alias_id
}
