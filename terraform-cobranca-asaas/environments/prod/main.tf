# ===========================
# Módulo SQS
# ===========================
module "sqs" {
  source = "../../modules/sqs-queue"
  
  queue_name                  = var.sqs_queue_name
  visibility_timeout_seconds  = var.sqs_visibility_timeout
  max_receive_count           = var.sqs_max_receive_count
  message_retention_days      = var.sqs_message_retention_days
  environment                 = var.environment
  enable_dlq_alarm            = var.enable_cloudwatch_alarms
  sns_alert_topic_arn         = var.sns_alert_topic_arn
}

# ===========================
# Módulo Lambda Worker
# ===========================
module "lambda_worker" {
  source = "../../modules/lambda-base"
  
  function_name        = "${var.project_name}-${var.environment}-worker"
  filename             = "${path.module}/../../lambdas/worker/lambda_function.zip"
  handler              = "lambda_function.lambda_handler"
  runtime              = var.lambda_runtime
  timeout              = var.lambda_timeout_worker
  memory_size          = var.lambda_memory_size
  reserved_concurrency = var.worker_reserved_concurrency
  environment          = var.environment
  
  environment_vars = {
    ASAAS_API_BASE_URL = var.asaas_api_base_url
    ASAAS_TOKEN        = var.asaas_token
    DATABASE_HOST      = var.database_host
    DATABASE_PORT      = tostring(var.database_port)
    DATABASE_NAME      = var.database_name
    DATABASE_USER      = var.database_user
    DATABASE_PASSWORD  = var.database_password
    DATABASE_TYPE      = var.database_type
    LOG_LEVEL          = var.environment == "prod" ? "INFO" : "DEBUG"
  }
  
  sqs_queue_arns = [module.sqs.main_queue_arn]
  
  event_source_arn        = module.sqs.main_queue_arn
  event_source_batch_size = 10
  event_source_enabled    = true
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# ===========================
# Módulo Lambda Orquestradora
# ===========================
module "lambda_orchestrator" {
  source = "../../modules/lambda-base"
  
  function_name = "${var.project_name}-${var.environment}-orchestrator"
  filename      = "${path.module}/../../lambdas/orchestrator/lambda_function.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout_orchestrator
  memory_size   = var.lambda_memory_size
  environment   = var.environment
  
  environment_vars = {
    SQS_QUEUE_URL      = module.sqs.main_queue_url
    DATABASE_HOST      = var.database_host
    DATABASE_PORT      = tostring(var.database_port)
    DATABASE_NAME      = var.database_name
    DATABASE_USER      = var.database_user
    DATABASE_PASSWORD  = var.database_password
    DATABASE_TYPE      = var.database_type
    LOG_LEVEL          = var.environment == "prod" ? "INFO" : "DEBUG"
  }
  
  additional_policy_statements = [
    {
      effect    = "Allow"
      actions   = ["sqs:SendMessage"]
      resources = [module.sqs.main_queue_arn]
    }
  ]
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# ===========================
# Módulo EventBridge
# ===========================
module "eventbridge" {
  source = "../../modules/eventbridge-trigger"
  
  rule_name            = "${var.project_name}-${var.environment}-daily-trigger"
  schedule_expression  = var.eventbridge_schedule
  timezone             = var.eventbridge_timezone
  target_function_arn  = module.lambda_orchestrator.function_arn
  target_function_name = "${var.project_name}-${var.environment}-orchestrator"
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# ===========================
# Módulo Lambda Webhook
# ===========================
module "lambda_webhook" {
  source = "../../modules/lambda-base"
  
  function_name = "${var.project_name}-${var.environment}-webhook-handler"
  filename      = "${path.module}/../../lambdas/webhook_handler/lambda_function.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout_webhook
  memory_size   = var.lambda_memory_size
  environment   = var.environment
  
  environment_vars = {
    DATABASE_HOST     = var.database_host
    DATABASE_PORT     = tostring(var.database_port)
    DATABASE_NAME     = var.database_name
    DATABASE_USER     = var.database_user
    DATABASE_PASSWORD = var.database_password
    DATABASE_TYPE     = var.database_type
    LOG_LEVEL         = var.environment == "prod" ? "INFO" : "DEBUG"
  }
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# ===========================
# Módulo API Gateway Webhook
# ===========================
module "api_gateway_webhook" {
  source = "../../modules/api-gateway-webhook"
  
  enabled              = var.enable_webhook_api
  api_name             = "${var.project_name}-${var.environment}-webhook-api"
  stage_name           = var.webhook_api_stage_name
  webhook_function_arn = module.lambda_webhook.function_arn
  webhook_function_name = "${var.project_name}-${var.environment}-webhook-handler"
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# ===========================
# Outputs
# ===========================
output "sqs_main_queue_url" {
  description = "URL da fila principal de cobranças"
  value       = module.sqs.main_queue_url
}

output "sqs_dlq_arn" {
  description = "ARN da Dead Letter Queue"
  value       = module.sqs.dlq_arn
}

output "lambda_worker_arn" {
  description = "ARN da Lambda Worker"
  value       = module.lambda_worker.function_arn
}

output "lambda_orchestrator_arn" {
  description = "ARN da Lambda Orquestradora"
  value       = module.lambda_orchestrator.function_arn
}

output "eventbridge_rule_arn" {
  description = "ARN da regra do EventBridge"
  value       = module.eventbridge.rule_arn
}

output "webhook_api_invoke_url" {
  description = "URL de invoke da API Gateway para webhook"
  value       = var.enable_webhook_api ? module.api_gateway_webhook.invoke_url : null
}

output "asaas_webhook_registration_payload" {
  description = "Payload JSON para registrar webhook no Asaas"
  value = var.enable_webhook_api ? {
    url     = "${module.api_gateway_webhook.invoke_url}/asaas-webhook"
    event   = "PAYMENT_RECEIVED"
    name    = "Cobrança ${var.environment}"
    enabled = true
  } : null
}