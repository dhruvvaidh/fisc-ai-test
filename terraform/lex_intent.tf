resource "aws_lexv2models_intent" "greeting_intent" {
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = aws_lexv2models_bot_locale.english_locale.bot_version
  name        = "GreetingIntent"
  locale_id   = aws_lexv2models_bot_locale.english_locale.locale_id

  description = "Handles greetings like hello, hi, etc."

  sample_utterance {
    utterance = "hello"
  }
  sample_utterance {
    utterance = "hi"
  }
  sample_utterance {
    utterance = "hey"
  }

  confirmation_setting {
    active = true

    prompt_specification {
      message_selection_strategy = "Ordered"
      max_retries                = 1
      allow_interrupt            = true

      message_group {
        message {
          plain_text_message {
            value = "what can i help you?"
          }
        }
      }
    }
  }

  fulfillment_code_hook {
    enabled = false
  }

  depends_on = [aws_lexv2models_bot_locale.english_locale]
}

resource "aws_lexv2models_intent" "goodbye_intent" {
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = aws_lexv2models_bot_locale.english_locale.bot_version
  name        = "GoodbyeIntent"
  locale_id   = aws_lexv2models_bot_locale.english_locale.locale_id

  description = "Handles goodbyes like bye, see ya, etc."

  sample_utterance {
    utterance = "bye"
  }

  sample_utterance {
    utterance = "goodbye"
  }

  sample_utterance {
    utterance = "see you later"
  }

  confirmation_setting {
    active = true

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 1
      message_selection_strategy = "Ordered"

      message_group {
        message {
          plain_text_message {
            value = "Are you sure you want to end the conversation?"
          }
        }
      }
    }
  }

  fulfillment_code_hook {
    enabled = true
  }

  depends_on = [aws_lexv2models_bot_locale.english_locale]
}

# -------------------------------------------------------------------
# 1) TransactionSearch intent
# -------------------------------------------------------------------
resource "aws_lexv2models_intent" "transaction_search" {
  name        = "TransactionSearch"
  description = "Find and list transactions filtered by merchant name and minimum amount criteria."
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id   = "en_US"

  sample_utterance { utterance = "Find my {Merchant} purchases over {MinAmount}" }
  sample_utterance { utterance = "Search transactions at {Merchant} above {MinAmount} dollars" }
  sample_utterance { utterance = "Show me transactions for {Merchant} greater than {MinAmount}" }
  sample_utterance { utterance = "List all {Merchant} orders above {MinAmount}" }
  sample_utterance { utterance = "What did I spend at {Merchant} over {MinAmount} ?" }

  fulfillment_code_hook {
    enabled = true
  }

  closing_setting {
    active = true
    closing_response {
      message_group {
        message {
          plain_text_message {
            value = "Is there anything else you’d like to know?"
          }
        } 
      }
      allow_interrupt = true
    }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}

# -------------------------------------------------------------------
# 2) Merchant slot
# -------------------------------------------------------------------
resource "aws_lexv2models_slot" "merchant_slot" {
  name         = "Merchant"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.transaction_search.intent_id
  slot_type_id = "AMAZON.AlphaNumeric"

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 1
      message_selection_strategy = "Random"
      message_group {
        message {
          plain_text_message {
            value = "Which merchant would you like to search for?"
          }
        }
      }
      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Initial"

        allowed_input_types {
          allow_audio_input = false
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Retry1"

        allowed_input_types {
          allow_audio_input = false
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }
    }
  }

  depends_on = [
    aws_lexv2models_intent.transaction_search
  ]
}

# -------------------------------------------------------------------
# 3) MinAmount slot
# -------------------------------------------------------------------
resource "aws_lexv2models_slot" "min_amount_slot" {
  name         = "MinAmount"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.transaction_search.intent_id
  slot_type_id = "AMAZON.Number"

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 1
      message_selection_strategy = "Random"
      message_group {
        message {
          plain_text_message {
            value = "What minimum amount should I use?"
          }
        }
      }
      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Initial"

        allowed_input_types {
          allow_audio_input = false
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Retry1"

        allowed_input_types {
          allow_audio_input = false
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }
    }
  }

  depends_on = [
    aws_lexv2models_intent.transaction_search
  ]
}

# -------------------------------------------------------------------
# 1) MonthlySummary intent
# -------------------------------------------------------------------
resource "aws_lexv2models_intent" "monthly_summary" {
  name        = "MonthlySummary"
  description = "Provide a breakdown of all expenses incurred during a specified month and year."
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id   = "en_US"

  sample_utterance { utterance = "Show my {Month} {Year} expenses" }
  sample_utterance { utterance = "What did I spend in {Month} of {Year}" }
  sample_utterance { utterance = "My expenses for {Month} {Year}" }
  sample_utterance { utterance = "List expenses in {Month} {Year}" }
  sample_utterance { utterance = "How much did I spend during {Month} {Year} ?" }

  fulfillment_code_hook {
    enabled = true
  }

  closing_setting {
    active = true
    closing_response {
      message_group {
        message {
          plain_text_message {
            value = "Let me know if there’s anything else you’d like to check."
          }
        }
      }
      allow_interrupt = true
    }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}

# -------------------------------------------------------------------
# 2) Month slot
# -------------------------------------------------------------------
resource "aws_lexv2models_slot" "month_slot" {
  name         = "Month"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.monthly_summary.intent_id
  slot_type_id = "AMAZON.Date"

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 1
      message_selection_strategy = "Random"
      message_group {
        message {
          plain_text_message {
            value = "Which month?"
          }
        }
      }
      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Initial"

        allowed_input_types {
          allow_audio_input = false
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Retry1"

        allowed_input_types {
          allow_audio_input = false
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

    }
    }

  depends_on = [
    aws_lexv2models_intent.monthly_summary
  ]
}

# -------------------------------------------------------------------
# 3) Year slot
# -------------------------------------------------------------------
resource "aws_lexv2models_slot" "year_slot" {
  name         = "Year"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.monthly_summary.intent_id
  slot_type_id = "AMAZON.Date"

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 1
      message_selection_strategy = "Random"
      message_group {
        message {
          plain_text_message {
            value = "Which year?"
          }
        }
      }
      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Initial"

        allowed_input_types {
          allow_audio_input = false
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Retry1"

        allowed_input_types {
          allow_audio_input = false
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }
    }
  }

  depends_on = [
    aws_lexv2models_intent.monthly_summary
  ]
}

# -------------------------------------------------------------------
# Update slot priorities for TransactionSearch
# -------------------------------------------------------------------
resource "null_resource" "update_transaction_search_slot_priority" {
  triggers = {
    bot_id               = aws_lexv2models_bot.finance_assistant.id
    intent_id            = aws_lexv2models_intent.transaction_search.intent_id
    merchant_slot_id     = aws_lexv2models_slot.merchant_slot.slot_id
    min_amount_slot_id   = aws_lexv2models_slot.min_amount_slot.slot_id
  }

  provisioner "local-exec" {
    command = <<EOT
      set -xe

      # Pull existing intent, strip metadata
      aws lexv2-models describe-intent \
        --bot-id ${self.triggers.bot_id} \
        --bot-version DRAFT \
        --locale-id en_US \
        --intent-id ${self.triggers.intent_id} \
        --output json > intent_config.json
      
      # Remove fields that cause issues
      jq 'del(.creationDateTime, .lastUpdatedDateTime, .version, .name)' \
        intent_config.json > clean_intent.json
      
      # Verify name is removed
      if jq -e 'has("name")' clean_intent.json; then
        echo "WARNING: name field still present, removing explicitly"
        jq 'del(.name)' clean_intent.json > final_intent.json
      else
        cp clean_intent.json final_intent.json
      fi

      # Inject our slot priorities
      jq --arg m "${self.triggers.merchant_slot_id}" \
         --arg n "${self.triggers.min_amount_slot_id}" \
         '.slotPriorities = [
             {"priority":1,"slotId": $m},
             {"priority":2,"slotId": $n}
           ]' \
        final_intent.json > updated_intent.json

      # Push it back
      aws lexv2-models update-intent \
        --bot-id ${self.triggers.bot_id} \
        --bot-version DRAFT \
        --locale-id en_US \
        --intent-id ${self.triggers.intent_id} \
        --cli-input-json file://updated_intent.json

      echo "✅ Updated slotPriority on TransactionSearch"
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    aws_lexv2models_intent.transaction_search,
    aws_lexv2models_slot.merchant_slot,
    aws_lexv2models_slot.min_amount_slot,
  ]
}


# -------------------------------------------------------------------
# Update slot priorities for MonthlySummary
# -------------------------------------------------------------------
resource "null_resource" "update_monthly_summary_slot_priority" {
  triggers = {
    bot_id          = aws_lexv2models_bot.finance_assistant.id
    intent_id       = aws_lexv2models_intent.monthly_summary.intent_id
    month_slot_id   = aws_lexv2models_slot.month_slot.slot_id
    year_slot_id    = aws_lexv2models_slot.year_slot.slot_id
  }

  provisioner "local-exec" {
    command = <<EOT
      set -xe

      # Pull existing intent, strip metadata
      aws lexv2-models describe-intent \
        --bot-id ${self.triggers.bot_id} \
        --bot-version DRAFT \
        --locale-id en_US \
        --intent-id ${self.triggers.intent_id} \
        --output json > intent_config.json
      jq 'del(.creationDateTime, .lastUpdatedDateTime, .version, .name)' \
        intent_config.json > tmp_intent_config.json && mv tmp_intent_config.json intent_config.json

      # Inject our two slot priorities
      jq --arg m "${self.triggers.month_slot_id}" \
         --arg y "${self.triggers.year_slot_id}" \
         '.slotPriorities = [
             {"priority":1,"slotId": $m},
             {"priority":2,"slotId": $y}
           ]' \
        intent_config.json > updated_intent.json

      # Push it back
      aws lexv2-models update-intent \
        --bot-id ${self.triggers.bot_id} \
        --bot-version DRAFT \
        --locale-id en_US \
        --intent-id ${self.triggers.intent_id} \
        --cli-input-json file://updated_intent.json

      echo "✅ Updated slotPriority on MonthlySummary"
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    aws_lexv2models_intent.monthly_summary,
    aws_lexv2models_slot.month_slot,
    aws_lexv2models_slot.year_slot,
  ]
}
