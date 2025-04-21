# Intent definition for querying spending by category
resource "aws_lexv2models_intent" "query_spending_by_category" {
  name        = "QuerySpendingByCategory"
  description = "Allows users to ask about spending in specific categories and time periods"
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id   = "en_US"

  # Sample utterances - making these diverse to handle various ways users might ask
  sample_utterance {
    utterance = "How much did I spend on {Category} {TimeFrame}"
  }
  sample_utterance {
    utterance = "What's my {Category} spending {TimeFrame}"
  }
  sample_utterance {
    utterance = "Show me my {Category} expenses {TimeFrame}"
  }
  sample_utterance {
    utterance = "Tell me about my {Category} purchases {TimeFrame}"
  }
  sample_utterance {
    utterance = "{Category} spending {TimeFrame}"
  }

  fulfillment_code_hook {
    enabled = true
  }

  closing_setting {
    active = true
    closing_response {
      message_group {
        message {
          plain_text_message {
            value = "Is there anything else you'd like to know about your spending?"
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

# Category slot
resource "aws_lexv2models_slot" "category_slot" {
  name         = "Category"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.query_spending_by_category.intent_id
  slot_type_id = aws_lexv2models_slot_type.spending_category_type.slot_type_id
  value_elicitation_setting {
    slot_constraint = "Required"
    
    prompt_specification {
      max_retries = 2  # This should match the number of retry specifications
      allow_interrupt = true
      
      message_group {
        message {
          plain_text_message {
            value = "Which spending category would you like to know about? For example: groceries, dining, entertainment, etc."
          }
        }
      }

      message_selection_strategy = "Random"

      # Initial prompt
      prompt_attempts_specification {
        map_block_key = "Initial"
        allow_interrupt = true

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            max_length_ms  = 15000
            end_timeout_ms = 640
          }
          dtmf_specification {
            max_length         = 20
            end_timeout_ms     = 5000
            deletion_character = "*"
            end_character      = "#"
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      # First retry
      prompt_attempts_specification {
        map_block_key = "Retry1"
        allow_interrupt = true

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            max_length_ms  = 15000
            end_timeout_ms = 640
          }
          dtmf_specification {
            max_length         = 20
            end_timeout_ms     = 5000
            deletion_character = "*"
            end_character      = "#"
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      # Second retry - Add this block
      prompt_attempts_specification {
        map_block_key = "Retry2"
        allow_interrupt = true

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            max_length_ms  = 15000
            end_timeout_ms = 640
          }
          dtmf_specification {
            max_length         = 20
            end_timeout_ms     = 5000
            deletion_character = "*"
            end_character      = "#"
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }
    }
  }
}

# Time frame slot
resource "aws_lexv2models_slot" "time_frame_slot" {
  name         = "TimeFrame"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.query_spending_by_category.intent_id
  slot_type_id = aws_lexv2models_slot_type.time_frame_type.slot_type_id

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
  max_retries     = 2
  allow_interrupt = true
  message_selection_strategy = "Random"

  message_group {
    message {
      plain_text_message {
        value = "For what time frame would you like to view your spending? (e.g., last week, this month)"
      }
    }
  }

  # Initial Attempt
  prompt_attempts_specification {
    map_block_key = "Initial"
    allow_interrupt = true

    allowed_input_types {
      allow_audio_input = true
      allow_dtmf_input  = true
    }

    text_input_specification {
      start_timeout_ms = 30000
    }

    audio_and_dtmf_input_specification {
      start_timeout_ms = 4000

      audio_specification {
        max_length_ms  = 15000
        end_timeout_ms = 640
      }

      dtmf_specification {
        max_length         = 513
        end_timeout_ms     = 5000
        deletion_character = "*"
        end_character      = "#"
      }
    }
  }

  # Retry 1
  prompt_attempts_specification {
    map_block_key = "Retry1"
    allow_interrupt = true

    allowed_input_types {
      allow_audio_input = true
      allow_dtmf_input  = true
    }

    text_input_specification {
      start_timeout_ms = 30000
    }

    audio_and_dtmf_input_specification {
      start_timeout_ms = 4000

      audio_specification {
        max_length_ms  = 15000
        end_timeout_ms = 640
      }

      dtmf_specification {
        max_length         = 513
        end_timeout_ms     = 5000
        deletion_character = "*"
        end_character      = "#"
      }
    }
  }

  # Retry 2
  prompt_attempts_specification {
    map_block_key = "Retry2"
    allow_interrupt = true

    allowed_input_types {
      allow_audio_input = true
      allow_dtmf_input  = true
    }

    text_input_specification {
      start_timeout_ms = 30000
    }

    audio_and_dtmf_input_specification {
      start_timeout_ms = 4000

      audio_specification {
        max_length_ms  = 15000
        end_timeout_ms = 640
      }

      dtmf_specification {
        max_length         = 513
        end_timeout_ms     = 5000
        deletion_character = "*"
        end_character      = "#"
      }
    }
  }
}

  }
}


# Category slot type
# Category slot type
# Category slot type
resource "aws_lexv2models_slot_type" "spending_category_type" {
  name         = "SpendingCategoryType"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  description  = "Categories of spending"

  value_selection_setting {
    resolution_strategy = "TopResolution"  # Changed from ORIGINAL_VALUE to TOP_RESOLUTION
  }

  # Use slot_type_values instead of enumeration_value
  slot_type_values {
    sample_value { value = "groceries" }
    synonyms { value = "grocery" }
    synonyms { value = "supermarket" }
    synonyms { value = "food shopping" }
  }
  
  slot_type_values {
    sample_value { value = "dining" }
    synonyms { value = "restaurants" }
    synonyms { value = "eating out" }
    synonyms { value = "food" }
  }
  
  slot_type_values {
    sample_value { value = "entertainment" }
    synonyms { value = "fun" }
    synonyms { value = "movies" }
    synonyms{ value = "shows" }
  }
  
  slot_type_values {
    sample_value { value = "shopping" }
    synonyms { value = "retail" }
    synonyms { value = "clothes" }
    synonyms { value = "purchases" }
  }
  
  slot_type_values {
    sample_value { value = "transportation" }
    synonyms { value = "transit" }
    synonyms { value = "travel" }
    synonyms { value = "commute" }
  }
  
  slot_type_values {
    sample_value { value = "utilities" }
    synonyms { value = "bills" }
    synonyms { value = "electricity" }
    synonyms { value = "water" }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}

# Time frame slot type
resource "aws_lexv2models_slot_type" "time_frame_type" {
  name         = "TimeFrameType"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  description  = "Time periods for queries"

  value_selection_setting {
    resolution_strategy = "TopResolution"  # Changed from ORIGINAL_VALUE to TOP_RESOLUTION
  }

  # Use slot_type_values instead of enumeration_value
  slot_type_values {
    sample_value { value = "today" }
    synonyms { value = "this day" }
  }
  
  slot_type_values {
    sample_value { value = "yesterday" }
  }
  
  slot_type_values {
    sample_value { value = "this week" }
    synonyms { value = "current week" }
  }
  
  slot_type_values {
    sample_value { value = "last week" }
    synonyms { value = "previous week" }
  }
  
  slot_type_values {
    sample_value { value = "this month" }
    synonyms { value = "current month" }
  }
  
  slot_type_values {
    sample_value { value = "last month" }
    synonyms { value = "previous month" }
  }
  
  slot_type_values {
    sample_value { value = "this year" }
    synonyms { value = "current year" }
  }
  
  slot_type_values {
    sample_value { value = "last year" }
    synonyms { value = "previous year" }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}
# The null resource to fix the slot priority circular dependency
resource "null_resource" "update_query_spending_by_category_slot_priorities" {
  triggers = {
    bot_id    = aws_lexv2models_bot.finance_assistant.id
    locale_id = "en_US"
    intent_id  = aws_lexv2models_intent.query_spending_by_category.intent_id
  }

  provisioner "local-exec" {
    command = <<EOT
      set -xe

      BOT_ID=${self.triggers.bot_id}
      LOCALE=${self.triggers.locale_id}
      INTENT_NAME="QuerySpendingByCategory"

      echo "🔍 Looking up intent ID for: $INTENT_NAME"
      INTENT_ID=$(aws lexv2-models list-intents \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --query "intentSummaries[?intentName=='$INTENT_NAME'].intentId" \
        --output text)

      if [[ -z "$INTENT_ID" ]]; then
        echo "❌ Intent '$INTENT_NAME' not found. Exiting."
        exit 1
      fi

      echo "🔍 Looking up slot IDs..."
      SLOT_ID_CATEGORY=$(aws lexv2-models list-slots \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --query "slotSummaries[?slotName=='Category'].slotId" \
        --output text)

      SLOT_ID_TIMEFRAME=$(aws lexv2-models list-slots \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --query "slotSummaries[?slotName=='TimeFrame'].slotId" \
        --output text)

      if [[ -z "$SLOT_ID_CATEGORY" || -z "$SLOT_ID_TIMEFRAME" ]]; then
        echo "❌ One or both slot IDs not found. Exiting."
        exit 1
      fi

      echo "✅ Slot IDs: Category=$SLOT_ID_CATEGORY, TimeFrame=$SLOT_ID_TIMEFRAME"

      echo "📄 Fetching intent definition..."
      aws lexv2-models describe-intent \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID | \
        jq 'del(.creationDateTime, .lastUpdatedDateTime, .version, .name)' > intent_config.json

      echo "🛠️ Injecting slot priorities..."
      jq --arg cat "$SLOT_ID_CATEGORY" --arg tf "$SLOT_ID_TIMEFRAME" \
        '.slotPriorities = [{"priority": 1, "slotId": $cat}, {"priority": 2, "slotId": $tf}]' \
        intent_config.json > updated_intent.json

      echo "🚀 Updating Lex intent..."
      aws lexv2-models update-intent \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --cli-input-json file://updated_intent.json

      echo "✅ Slot priorities successfully updated for '$INTENT_NAME'"
    EOT
  }

  depends_on = [ 
    aws_lexv2models_intent.query_spending_by_category,
    aws_lexv2models_slot.category_slot,
    aws_lexv2models_slot.time_frame_slot
  ]
}


