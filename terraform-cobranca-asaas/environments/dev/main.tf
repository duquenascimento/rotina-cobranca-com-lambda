module "cobranca_asaas" {
  source = "../../"
  
  # AWS & Projeto
  aws_region     = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  project_name   = var.project_name
  environment    = var.environment
  
  # Lambdas
  lambda_runtime                = var.lambda_runtime
  lambda_timeout_orchestrator   = var.lambda_timeout_orchestrator
  lambda_timeout_worker         = var.lambda_timeout_worker
  lambda_timeout_webhook        = var.lambda_timeout_webhook
  lambda_memory_size            = var.lambda_memory_size
  worker_reserved_concurrency   = var.worker_reserved_concurrency
  
  # SQS
  sqs_queue_name             = var.sqs_queue_name
  sqs_visibility_timeout     = var.sqs_visibility_timeout
  sqs_max_receive_count      = var.sqs_max_receive_count
  sqs_message_retention_days = var.sqs_message_retention_days
  
  # EventBridge
  eventbridge_schedule = var.eventbridge_schedule
  eventbridge_timezone = var.eventbridge_timezone
  
  # Database
  database_type     = var.database_type
  database_host     = var.database_host
  database_port     = var.database_port
  database_name     = var.database_name
  database_user     = var.database_user
  database_password = var.database_password
  
  # Asaas
  asaas_api_base_url = var.asaas_api_base_url
  asaas_token        = var.asaas_token
  
  # Webhook
  enable_webhook_api     = var.enable_webhook_api
  webhook_api_stage_name = var.webhook_api_stage_name
  
  # Alertas
  enable_cloudwatch_alarms = var.enable_cloudwatch_alarms
  sns_alert_topic_arn      = var.sns_alert_topic_arn
}

# Outputs
output "sqs_queue_url" {
  value = module.cobranca_asaas.sqs_queue_url
}

output "webhook_url" {
  value = module.cobranca_asaas.webhook_url
}

output "asaas_webhook_payload" {
  value = {
    url     = module.cobranca_asaas.webhook_url
    event   = "PAYMENT_RECEIVED"
    name    = "Cobrança ${var.environment}"
    enabled = true
  }
}