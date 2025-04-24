#locals {
#  transaction_categories = jsondecode(
#    file("${path.module}/transaction_categories.json")
#  )
#}

# Intent definition for querying spending by category
resource "aws_lexv2models_intent" "get_spending_by_category" {
  name        = "GetSpendingByCategory"
  description = "Retrieve the total amount spent in a specified category over a given time period."
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = aws_lexv2models_bot_locale.english_locale.bot_version
  locale_id   = aws_lexv2models_bot_locale.english_locale.locale_id

  # Sample utterances
  sample_utterance { utterance = "How much did I spend on {Category} last month" }
  sample_utterance { utterance = "Show me my {Category} expenses for {TimePeriod}" }
  sample_utterance { utterance = "What did I spend on {Category} in {TimePeriod}" }
  sample_utterance { utterance = "Give me my {Category} spending for {TimePeriod}" }
  sample_utterance { utterance = "My spending on {Category} {TimePeriod}" }
  sample_utterance { utterance = "I spent how much on {Category} {TimePeriod} ?" }

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
    aws_lexv2models_slot_type.category,
    aws_lexv2models_bot_locale.english_locale
  ]
}
# Category slot
resource "aws_lexv2models_slot" "category_slot" {
  name         = "Category"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.get_spending_by_category.intent_id
  slot_type_id = aws_lexv2models_slot_type.category.slot_type_id
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
resource "aws_lexv2models_slot" "time_period_slot" {
  name         = "TimePeriod"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.get_spending_by_category.intent_id
  slot_type_id = "AMAZON.Date"

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
resource "aws_lexv2models_slot_type" "category" {
  name        = "Category"
  description = "Custom slot type for transaction categories"
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id   = "en_US"

  value_selection_setting { resolution_strategy = "TopResolution" }

  #dynamic "slot_type_values" {
  #  for_each = local.transaction_categories
  #  content {
  #    sample_value { value = slot_type_values.value.sampleValue.value }
  #    synonyms       = slot_type_values.value.synonyms
  #  }
  #}

  slot_type_values {
    sample_value { value = “INCOME” }
    synonyms { value = “INCOME_DIVIDENDS” }
    synonyms { value = “dividends” }
    synonyms { value = “income dividends” }
    synonyms { value = “INCOME_INTEREST_EARNED” }
    synonyms { value = “income interest earned” }
    synonyms { value = “interest earned” }
    synonyms { value = “INCOME_RETIREMENT_PENSION” }
    synonyms { value = “income retirement pension” }
    synonyms { value = “retirement pension” }
    synonyms { value = “INCOME_TAX_REFUND” }
    synonyms { value = “income tax refund” }
    synonyms { value = “tax refund” }
    synonyms { value = “INCOME_UNEMPLOYMENT” }
    synonyms { value = “unemployment” }
    synonyms { value = “income unemployment” }
    synonyms { value = “INCOME_WAGES” }
    synonyms { value = “income wages” }
    synonyms { value = “wages” }
    synonyms { value = “INCOME_OTHER_INCOME” }
    synonyms { value = “income other income” }
    synonyms { value = “other income” }
    synonyms { value = “earnings” }
    synonyms { value = “revenue” }
    synonyms { value = “pay” }
    }
    
  slot_type_values {
      sample_value { value = “TRANSFER_IN” }
      synonyms { value = “TRANSFER_IN_CASH_ADVANCES_AND_LOANS” }
      synonyms { value = “in cash advances and loans” }
      synonyms { value = “transfer in cash advances and loans” }
      synonyms { value = “TRANSFER_IN_DEPOSIT” }
      synonyms { value = “transfer in deposit” }
      synonyms { value = “in deposit” }
      synonyms { value = “TRANSFER_IN_INVESTMENT_AND_RETIREMENT_FUNDS” }
      synonyms { value = “in investment and retirement funds” }
      synonyms { value = “transfer in investment and retirement funds” }
      synonyms { value = “TRANSFER_IN_SAVINGS” }
      synonyms { value = “in savings” }
      synonyms { value = “transfer in savings” }
      synonyms { value = “TRANSFER_IN_ACCOUNT_TRANSFER” }
      synonyms { value = “in account transfer” }
      synonyms { value = “transfer in account transfer” }
      synonyms { value = “TRANSFER_IN_OTHER_TRANSFER_IN” }
      synonyms { value = “transfer in other transfer in” }
      synonyms { value = “in other transfer in” }
      synonyms { value = “deposit” }
      synonyms { value = “incoming transfer” }
    }
  
  slot_type_values {
      sample_value { value = “TRANSFER_OUT” }
      synonyms { value = “TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS” }
      synonyms { value = “transfer out investment and retirement funds” }
      synonyms { value = “out investment and retirement funds” }
      synonyms { value = “TRANSFER_OUT_SAVINGS” }
      synonyms { value = “out savings” }
      synonyms { value = “transfer out savings” }
      synonyms { value = “TRANSFER_OUT_WITHDRAWAL” }
      synonyms { value = “out withdrawal” }
      synonyms { value = “transfer out withdrawal” }
      synonyms { value = “TRANSFER_OUT_ACCOUNT_TRANSFER” }
      synonyms { value = “transfer out account transfer” }
      synonyms { value = “out account transfer” }
      synonyms { value = “TRANSFER_OUT_OTHER_TRANSFER_OUT” }
      synonyms { value = “transfer out other transfer out” }
      synonyms { value = “out other transfer out” }
      synonyms { value = “withdrawal” }
      synonyms { value = “outgoing transfer” }
    }
  
  slot_type_values {
      sample_value { value = “LOAN_PAYMENTS” }
      synonyms { value = “LOAN_PAYMENTS_CAR_PAYMENT” }
      synonyms { value = “loan payments car payment” }
      synonyms { value = “payments car payment” }
      synonyms { value = “LOAN_PAYMENTS_CREDIT_CARD_PAYMENT” }
      synonyms { value = “loan payments credit card payment” }
      synonyms { value = “payments credit card payment” }
      synonyms { value = “LOAN_PAYMENTS_PERSONAL_LOAN_PAYMENT” }
      synonyms { value = “payments personal loan payment” }
      synonyms { value = “loan payments personal loan payment” }
      synonyms { value = “LOAN_PAYMENTS_MORTGAGE_PAYMENT” }
      synonyms { value = “payments mortgage payment” }
      synonyms { value = “loan payments mortgage payment” }
      synonyms { value = “LOAN_PAYMENTS_STUDENT_LOAN_PAYMENT” }
      synonyms { value = “payments student loan payment” }
      synonyms { value = “loan payments student loan payment” }
      synonyms { value = “LOAN_PAYMENTS_OTHER_PAYMENT” }
      synonyms { value = “loan payments other payment” }
      synonyms { value = “payments other payment” }
      synonyms { value = “loan repayment” }
      synonyms { value = “loan installment” }
    }
  
  slot_type_values {
      sample_value { value = “BANK_FEES” }
      synonyms { value = “BANK_FEES_ATM_FEES” }
      synonyms { value = “bank fees atm fees” }
      synonyms { value = “fees atm fees” }
      synonyms { value = “BANK_FEES_FOREIGN_TRANSACTION_FEES” }
      synonyms { value = “bank fees foreign transaction fees” }
      synonyms { value = “fees foreign transaction fees” }
      synonyms { value = “BANK_FEES_INSUFFICIENT_FUNDS” }
      synonyms { value = “bank fees insufficient funds” }
      synonyms { value = “fees insufficient funds” }
      synonyms { value = “BANK_FEES_INTEREST_CHARGE” }
      synonyms { value = “bank fees interest charge” }
      synonyms { value = “fees interest charge” }
      synonyms { value = “BANK_FEES_OVERDRAFT_FEES” }
      synonyms { value = “bank fees overdraft fees” }
      synonyms { value = “fees overdraft fees” }
      synonyms { value = “BANK_FEES_OTHER_BANK_FEES” }
      synonyms { value = “bank fees other bank fees” }
      synonyms { value = “fees other bank fees” }
      synonyms { value = “bank charge” }
      synonyms { value = “fees” }
    }
  
  slot_type_values {
      sample_value { value = “ENTERTAINMENT” }
      synonyms { value = “ENTERTAINMENT_CASINOS_AND_GAMBLING” }
      synonyms { value = “casinos and gambling” }
      synonyms { value = “entertainment casinos and gambling” }
      synonyms { value = “ENTERTAINMENT_MUSIC_AND_AUDIO” }
      synonyms { value = “entertainment music and audio” }
      synonyms { value = “music and audio” }
      synonyms { value = “ENTERTAINMENT_SPORTING_EVENTS_AMUSEMENT_PARKS_AND_MUSEUMS” }
      synonyms { value = “entertainment sporting events amusement parks and museums” }
      synonyms { value = “sporting events amusement parks and museums” }
      synonyms { value = “ENTERTAINMENT_TV_AND_MOVIES” }
      synonyms { value = “entertainment tv and movies” }
      synonyms { value = “tv and movies” }
      synonyms { value = “ENTERTAINMENT_VIDEO_GAMES” }
      synonyms { value = “video games” }
      synonyms { value = “entertainment video games” }
      synonyms { value = “ENTERTAINMENT_OTHER_ENTERTAINMENT” }
      synonyms { value = “entertainment other entertainment” }
      synonyms { value = “other entertainment” }
      synonyms { value = “leisure” }
      synonyms { value = “fun” }
    }
  
  slot_type_values {
      sample_value { value = “FOOD_AND_DRINK” }
      synonyms { value = “FOOD_AND_DRINK_BEER_WINE_AND_LIQUOR” }
      synonyms { value = “food and drink beer wine and liquor” }
      synonyms { value = “and drink beer wine and liquor” }
      synonyms { value = “FOOD_AND_DRINK_COFFEE” }
      synonyms { value = “and drink coffee” }
      synonyms { value = “food and drink coffee” }
      synonyms { value = “FOOD_AND_DRINK_FAST_FOOD” }
      synonyms { value = “and drink fast food” }
      synonyms { value = “food and drink fast food” }
      synonyms { value = “FOOD_AND_DRINK_GROCERIES” }
      synonyms { value = “food and drink groceries” }
      synonyms { value = “and drink groceries” }
      synonyms { value = “FOOD_AND_DRINK_RESTAURANT” }
      synonyms { value = “food and drink restaurant” }
      synonyms { value = “and drink restaurant” }
      synonyms { value = “FOOD_AND_DRINK_VENDING_MACHINES” }
      synonyms { value = “and drink vending machines” }
      synonyms { value = “food and drink vending machines” }
      synonyms { value = “FOOD_AND_DRINK_OTHER_FOOD_AND_DRINK” }
      synonyms { value = “food and drink other food and drink” }
      synonyms { value = “and drink other food and drink” }
      synonyms { value = “food” }
      synonyms { value = “meal” }
      synonyms { value = “beverage” }
    }
  
  slot_type_values {
      sample_value { value = “GENERAL_MERCHANDISE” }
      synonyms { value = “GENERAL_MERCHANDISE_BOOKSTORES_AND_NEWSSTANDS” }
      synonyms { value = “merchandise bookstores and newsstands” }
      synonyms { value = “general merchandise bookstores and newsstands” }
      synonyms { value = “GENERAL_MERCHANDISE_CLOTHING_AND_ACCESSORIES” }
      synonyms { value = “general merchandise clothing and accessories” }
      synonyms { value = “merchandise clothing and accessories” }
      synonyms { value = “GENERAL_MERCHANDISE_CONVENIENCE_STORES” }
      synonyms { value = “general merchandise convenience stores” }
      synonyms { value = “merchandise convenience stores” }
      synonyms { value = “GENERAL_MERCHANDISE_DEPARTMENT_STORES” }
      synonyms { value = “general merchandise department stores” }
      synonyms { value = “merchandise department stores” }
      synonyms { value = “GENERAL_MERCHANDISE_DISCOUNT_STORES” }
      synonyms { value = “merchandise discount stores” }
      synonyms { value = “general merchandise discount stores” }
      synonyms { value = “GENERAL_MERCHANDISE_ELECTRONICS” }
      synonyms { value = “merchandise electronics” }
      synonyms { value = “general merchandise electronics” }
      synonyms { value = “GENERAL_MERCHANDISE_GIFTS_AND_NOVELTIES” }
      synonyms { value = “merchandise gifts and novelties” }
      synonyms { value = “general merchandise gifts and novelties” }
      synonyms { value = “GENERAL_MERCHANDISE_OFFICE_SUPPLIES” }
      synonyms { value = “merchandise office supplies” }
      synonyms { value = “general merchandise office supplies” }
      synonyms { value = “GENERAL_MERCHANDISE_ONLINE_MARKETPLACES” }
      synonyms { value = “general merchandise online marketplaces” }
      synonyms { value = “merchandise online marketplaces” }
      synonyms { value = “GENERAL_MERCHANDISE_PET_SUPPLIES” }
      synonyms { value = “general merchandise pet supplies” }
      synonyms { value = “merchandise pet supplies” }
      synonyms { value = “GENERAL_MERCHANDISE_SPORTING_GOODS” }
      synonyms { value = “merchandise sporting goods” }
      synonyms { value = “general merchandise sporting goods” }
      synonyms { value = “GENERAL_MERCHANDISE_SUPERSTORES” }
      synonyms { value = “merchandise superstores” }
      synonyms { value = “general merchandise superstores” }
      synonyms { value = “GENERAL_MERCHANDISE_TOBACCO_AND_VAPE” }
      synonyms { value = “merchandise tobacco and vape” }
      synonyms { value = “general merchandise tobacco and vape” }
      synonyms { value = “GENERAL_MERCHANDISE_OTHER_GENERAL_MERCHANDISE” }
      synonyms { value = “merchandise other general merchandise” }
      synonyms { value = “general merchandise other general merchandise” }
      synonyms { value = “shopping” }
      synonyms { value = “retail” }
    }
  
  slot_type_values {
      sample_value { value = “HOME_IMPROVEMENT” }
      synonyms { value = “HOME_IMPROVEMENT_FURNITURE” }
      synonyms { value = “improvement furniture” }
      synonyms { value = “home improvement furniture” }
      synonyms { value = “HOME_IMPROVEMENT_HARDWARE” }
      synonyms { value = “improvement hardware” }
      synonyms { value = “home improvement hardware” }
      synonyms { value = “HOME_IMPROVEMENT_REPAIR_AND_MAINTENANCE” }
      synonyms { value = “improvement repair and maintenance” }
      synonyms { value = “home improvement repair and maintenance” }
      synonyms { value = “HOME_IMPROVEMENT_SECURITY” }
      synonyms { value = “improvement security” }
      synonyms { value = “home improvement security” }
      synonyms { value = “HOME_IMPROVEMENT_OTHER_HOME_IMPROVEMENT” }
      synonyms { value = “improvement other home improvement” }
      synonyms { value = “home improvement other home improvement” }
      synonyms { value = “home repair” }
      synonyms { value = “home maintenance” }
    }
  
  slot_type_values {
      sample_value { value = “MEDICAL” }
      synonyms { value = “MEDICAL_DENTAL_CARE” }
      synonyms { value = “dental care” }
      synonyms { value = “medical dental care” }
      synonyms { value = “MEDICAL_EYE_CARE” }
      synonyms { value = “eye care” }
      synonyms { value = “medical eye care” }
      synonyms { value = “MEDICAL_NURSING_CARE” }
      synonyms { value = “medical nursing care” }
      synonyms { value = “nursing care” }
      synonyms { value = “MEDICAL_PHARMACIES_AND_SUPPLEMENTS” }
      synonyms { value = “pharmacies and supplements” }
      synonyms { value = “medical pharmacies and supplements” }
      synonyms { value = “MEDICAL_PRIMARY_CARE” }
      synonyms { value = “medical primary care” }
      synonyms { value = “primary care” }
      synonyms { value = “MEDICAL_VETERINARY_SERVICES” }
      synonyms { value = “veterinary services” }
      synonyms { value = “medical veterinary services” }
      synonyms { value = “MEDICAL_OTHER_MEDICAL” }
      synonyms { value = “other medical” }
      synonyms { value = “medical other medical” }
      synonyms { value = “healthcare” }
      synonyms { value = “medical services” }
    }
  
  slot_type_values {
      sample_value { value = “PERSONAL_CARE” }
      synonyms { value = “PERSONAL_CARE_GYMS_AND_FITNESS_CENTERS” }
      synonyms { value = “personal care gyms and fitness centers” }
      synonyms { value = “care gyms and fitness centers” }
      synonyms { value = “PERSONAL_CARE_HAIR_AND_BEAUTY” }
      synonyms { value = “personal care hair and beauty” }
      synonyms { value = “care hair and beauty” }
      synonyms { value = “PERSONAL_CARE_LAUNDRY_AND_DRY_CLEANING” }
      synonyms { value = “personal care laundry and dry cleaning” }
      synonyms { value = “care laundry and dry cleaning” }
      synonyms { value = “PERSONAL_CARE_OTHER_PERSONAL_CARE” }
      synonyms { value = “care other personal care” }
      synonyms { value = “personal care other personal care” }
      synonyms { value = “self-care” }
      synonyms { value = “grooming” }
    }
  
  slot_type_values {
      sample_value { value = “GENERAL_SERVICES” }
      synonyms { value = “GENERAL_SERVICES_ACCOUNTING_AND_FINANCIAL_PLANNING” }
      synonyms { value = “general services accounting and financial planning” }
      synonyms { value = “services accounting and financial planning” }
      synonyms { value = “GENERAL_SERVICES_AUTOMOTIVE” }
      synonyms { value = “general services automotive” }
      synonyms { value = “services automotive” }
      synonyms { value = “GENERAL_SERVICES_CHILDCARE” }
      synonyms { value = “general services childcare” }
      synonyms { value = “services childcare” }
      synonyms { value = “GENERAL_SERVICES_CONSULTING_AND_LEGAL” }
      synonyms { value = “general services consulting and legal” }
      synonyms { value = “services consulting and legal” }
      synonyms { value = “GENERAL_SERVICES_EDUCATION” }
      synonyms { value = “services education” }
      synonyms { value = “general services education” }
      synonyms { value = “GENERAL_SERVICES_INSURANCE” }
      synonyms { value = “services insurance” }
      synonyms { value = “general services insurance” }
      synonyms { value = “GENERAL_SERVICES_POSTAGE_AND_SHIPPING” }
      synonyms { value = “services postage and shipping” }
      synonyms { value = “general services postage and shipping” }
      synonyms { value = “GENERAL_SERVICES_STORAGE” }
      synonyms { value = “general services storage” }
      synonyms { value = “services storage” }
      synonyms { value = “GENERAL_SERVICES_OTHER_GENERAL_SERVICES” }
      synonyms { value = “general services other general services” }
      synonyms { value = “services other general services” }
      synonyms { value = “services” }
      synonyms { value = “service” }
    }
  
  slot_type_values {
      sample_value { value = “GOVERNMENT_AND_NON_PROFIT” }
      synonyms { value = “GOVERNMENT_AND_NON_PROFIT_DONATIONS” }
      synonyms { value = “government and non profit donations” }
      synonyms { value = “and non profit donations” }
      synonyms { value = “GOVERNMENT_AND_NON_PROFIT_GOVERNMENT_DEPARTMENTS_AND_AGENCIES” }
      synonyms { value = “and non profit government departments and agencies” }
      synonyms { value = “government and non profit government departments and agencies” }
      synonyms { value = “GOVERNMENT_AND_NON_PROFIT_TAX_PAYMENT” }
      synonyms { value = “and non profit tax payment” }
      synonyms { value = “government and non profit tax payment” }
      synonyms { value = “GOVERNMENT_AND_NON_PROFIT_OTHER_GOVERNMENT_AND_NON_PROFIT” }
      synonyms { value = “government and non profit other government and non profit” }
      synonyms { value = “and non profit other government and non profit” }
      synonyms { value = “charity” }
      synonyms { value = “government services” }
    }
  
  slot_type_values {
      sample_value { value = “TRANSPORTATION” }
      synonyms { value = “TRANSPORTATION_BIKES_AND_SCOOTERS” }
      synonyms { value = “bikes and scooters” }
      synonyms { value = “transportation bikes and scooters” }
      synonyms { value = “TRANSPORTATION_GAS” }
      synonyms { value = “transportation gas” }
      synonyms { value = “gas” }
      synonyms { value = “TRANSPORTATION_PARKING” }
      synonyms { value = “parking” }
      synonyms { value = “transportation parking” }
      synonyms { value = “TRANSPORTATION_PUBLIC_TRANSIT” }
      synonyms { value = “transportation public transit” }
      synonyms { value = “public transit” }
      synonyms { value = “TRANSPORTATION_TAXIS_AND_RIDE_SHARES” }
      synonyms { value = “taxis and ride shares” }
      synonyms { value = “transportation taxis and ride shares” }
      synonyms { value = “TRANSPORTATION_TOLLS” }
      synonyms { value = “tolls” }
      synonyms { value = “transportation tolls” }
      synonyms { value = “TRANSPORTATION_OTHER_TRANSPORTATION” }
      synonyms { value = “transportation other transportation” }
      synonyms { value = “other transportation” }
      synonyms { value = “transport” }
      synonyms { value = “transportation services” }
    }
  
  slot_type_values {
      sample_value { value = “TRAVEL” }
      synonyms { value = “TRAVEL_FLIGHTS” }
      synonyms { value = “travel flights” }
      synonyms { value = “flights” }
      synonyms { value = “TRAVEL_LODGING” }
      synonyms { value = “travel lodging” }
      synonyms { value = “lodging” }
      synonyms { value = “TRAVEL_RENTAL_CARS” }
      synonyms { value = “rental cars” }
      synonyms { value = “travel rental cars” }
      synonyms { value = “TRAVEL_OTHER_TRAVEL” }
      synonyms { value = “travel other travel” }
      synonyms { value = “other travel” }
      synonyms { value = “trip” }
      synonyms { value = “journey” }
   }
  
  slot_type_values {
      sample_value { value = “RENT_AND_UTILITIES” }
      synonyms { value = “RENT_AND_UTILITIES_GAS_AND_ELECTRICITY” }
      synonyms { value = “rent and utilities gas and electricity” }
      synonyms { value = “and utilities gas and electricity” }
      synonyms { value = “RENT_AND_UTILITIES_INTERNET_AND_CABLE” }
      synonyms { value = “rent and utilities internet and cable” }
      synonyms { value = “and utilities internet and cable” }
      synonyms { value = “RENT_AND_UTILITIES_RENT” }
      synonyms { value = “rent and utilities rent” }
      synonyms { value = “and utilities rent” }
      synonyms { value = “RENT_AND_UTILITIES_SEWAGE_AND_WASTE_MANAGEMENT” }
      synonyms { value = “and utilities sewage and waste management” }
      synonyms { value = “rent and utilities sewage and waste management” }
      synonyms { value = “RENT_AND_UTILITIES_TELEPHONE” }
      synonyms { value = “and utilities telephone” }
      synonyms { value = “rent and utilities telephone” }
      synonyms { value = “RENT_AND_UTILITIES_WATER” }
      synonyms { value = “rent and utilities water” }
      synonyms { value = “and utilities water” }
      synonyms { value = “RENT_AND_UTILITIES_OTHER_UTILITIES” }
      synonyms { value = “and utilities other utilities” }
      synonyms { value = “rent and utilities other utilities” }
      synonyms { value = “rent” }
      synonyms { value = “utilities” }
   }
  
    

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}


# The null resource to fix the slot priority circular dependency
resource "null_resource" "update_get_spending_by_category_slot_priorities" {
  triggers = {
    bot_id    = aws_lexv2models_bot.finance_assistant.id
    locale_id = "en_US"
    intent_id  = aws_lexv2models_intent.get_spending_by_category.intent_id
  }

  provisioner "local-exec" {
    command = <<EOT
      set -xe

      BOT_ID=${self.triggers.bot_id}
      LOCALE=${self.triggers.locale_id}
      INTENT_NAME="GetSpendingByCategory"

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

      SLOT_ID_TIMEPERIOD=$(aws lexv2-models list-slots \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --query "slotSummaries[?slotName=='TimePeriod'].slotId" \
        --output text)

      if [[ -z "$SLOT_ID_CATEGORY" || -z "$SLOT_ID_TIMEPERIOD" ]]; then
        echo "❌ One or both slot IDs not found. Exiting."
        exit 1
      fi

      echo "✅ Slot IDs: Category=$SLOT_ID_CATEGORY, TimeFrame=$SLOT_ID_TIMEPERIOD"

      echo "📄 Fetching intent definition..."
      aws lexv2-models describe-intent \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID | \
        jq 'del(.creationDateTime, .lastUpdatedDateTime, .version, .name)' > intent_config.json

      echo "🛠️ Injecting slot priorities..."
      jq --arg cat "$SLOT_ID_CATEGORY" --arg tp "$SLOT_ID_TIMEPERIOD" \
        '.slotPriorities = [{"priority": 1, "slotId": $cat}, {"priority": 2, "slotId": $tp}]' \
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
    aws_lexv2models_intent.get_spending_by_category,
    aws_lexv2models_slot.category_slot,
    aws_lexv2models_slot.time_period_slot
  ]
}
