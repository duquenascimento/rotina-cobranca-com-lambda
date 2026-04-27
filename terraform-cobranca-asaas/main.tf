# ===========================
# Secrets Manager (placeholders)
# ===========================
resource "aws_secretsmanager_secret" "asaas_token" {
  count = var.environment == "dev" ? 1 : 0 # Só cria em dev; em prod use secret já existente
  name  = "${local.resource_prefix}/asaas/token"
  description = "Token de acesso para API do Asaas"
  tags = local.common_tags
}

resource "aws_secretsmanager_secret" "db_connection" {
  count = var.environment == "dev" ? 1 : 0
  name  = "${local.resource_prefix}/database/connection"
  description = "String de conexão do banco de dados"
  tags = local.common_tags
}

# ===========================
# Módulo SQS + DLQ
# ===========================
module "sqs" {
  source = "./modules/sqs-queue"
  
  queue_name                  = local.sqs_queue_name
  visibility_timeout_seconds  = var.sqs_visibility_timeout
  max_receive_count           = var.sqs_max_receive_count
  message_retention_days      = var.sqs_message_retention_days
  environment                 = var.environment
  
  enable_dlq_alarm            = var.enable_cloudwatch_alarms
  sns_alert_topic_arn         = var.sns_alert_topic_arn
}

# ===========================
# Módulo Lambda Worker (Consumer SQS)
# ===========================
module "lambda_worker" {
  source = "./modules/lambda-base"
  
  function_name        = local.lambda_worker_name
  filename             = "${local.lambda_source_paths.worker}/lambda_function.zip"
  handler              = "lambda_function.lambda_handler"
  runtime              = var.lambda_runtime
  timeout              = var.lambda_timeout_worker
  memory_size          = var.lambda_memory_size
  reserved_concurrency = var.worker_reserved_concurrency
  
  # Environment variables
  environment_vars = {
    ASAAS_API_BASE_URL      = var.asaas_api_base_url
    ASAAS_TOKEN_SECRET_ARN  = var.asaas_token_secret_arn
    DB_CONNECTION_SECRET_ARN = var.database_connection_secret_arn
    DATABASE_TYPE           = var.database_type
    LOG_LEVEL               = var.environment == "prod" ? "INFO" : "DEBUG"
  }
  
  # Permissões
  sqs_queue_arns = [module.sqs.main_queue_arn]
  secret_arns    = [var.asaas_token_secret_arn, var.database_connection_secret_arn]
  
  # Trigger SQS
  event_source_arn   = module.sqs.main_queue_arn
  event_source_batch_size = 10
  event_source_enabled    = true
  
  tags = local.common_tags
}

# ===========================
# Módulo Lambda Orquestradora (Producer)
# ===========================
module "lambda_orchestrator" {
  source = "./modules/lambda-base"
  
  function_name = local.lambda_orchestrator_name
  filename      = "${local.lambda_source_paths.orchestrator}/lambda_function.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout_orchestrator
  memory_size   = var.lambda_memory_size
  
  environment_vars = {
    SQS_QUEUE_URL           = module.sqs.main_queue_url
    DB_CONNECTION_SECRET_ARN = var.database_connection_secret_arn
    DATABASE_TYPE           = var.database_type
    LOG_LEVEL               = var.environment == "prod" ? "INFO" : "DEBUG"
  }
  
  secret_arns = [var.database_connection_secret_arn]
  
  # Permissão para enviar para SQS
  additional_policy_statements = [
    {
      effect = "Allow"
      actions = ["sqs:SendMessage"]
      resources = [module.sqs.main_queue_arn]
    }
  ]
  
  tags = local.common_tags
}

# ===========================
# Módulo EventBridge Trigger
# ===========================
module "eventbridge" {
  source = "./modules/eventbridge-trigger"
  
  rule_name           = local.eventbridge_rule_name
  schedule_expression = var.eventbridge_schedule
  timezone            = var.eventbridge_timezone
  target_function_arn = module.lambda_orchestrator.function_arn
  target_function_name = local.lambda_orchestrator_name
  
  tags = local.common_tags
}

# ===========================
# Módulo API Gateway Webhook (Opcional)
# ===========================
module "api_gateway_webhook" {
  source = "./modules/api-gateway-webhook"
  
  enabled              = var.enable_webhook_api
  api_name             = local.api_gateway_name
  stage_name           = var.webhook_api_stage_name
  webhook_function_arn = module.lambda_webhook.function_arn
  webhook_function_name = local.lambda_webhook_name
  
  tags = local.common_tags
}

# ===========================
# Módulo Lambda Webhook Handler
# ===========================
module "lambda_webhook" {
  source = "./modules/lambda-base"
  
  function_name = local.lambda_webhook_name
  filename      = "${local.lambda_source_paths.webhook}/lambda_function.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout_webhook
  memory_size   = var.lambda_memory_size
  
  environment_vars = {
    DB_CONNECTION_SECRET_ARN = var.database_connection_secret_arn
    DATABASE_TYPE           = var.database_type
    LOG_LEVEL               = var.environment == "prod" ? "INFO" : "DEBUG"
  }
  
  secret_arns = [var.database_connection_secret_arn]
  
  tags = local.common_tags
}