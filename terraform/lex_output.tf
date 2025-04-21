

data "external" "lex_alias_id" {
  program = ["bash", "-c", <<EOT
    ALIAS_ID=$(aws lexv2-models list-bot-aliases \
      --bot-id ${aws_lexv2models_bot.finance_assistant.id} \
      --query "botAliasSummaries[?botAliasName=='financeAssistantAlias'].botAliasId | [0]" \
      --output text)

    echo "{\"lex_bot_alias_id\": \"$ALIAS_ID\"}"
  EOT
  ]

  depends_on = [
    null_resource.create_lex_alias
  ]
}
