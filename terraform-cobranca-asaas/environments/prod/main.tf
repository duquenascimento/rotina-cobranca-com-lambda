# ===========================
# Provider Configuration
# ===========================
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ===========================
# Módulo Principal da Arquitetura
# ===========================
module "cobranca_asaas" {
  source = "../../" # Referência à raiz do terraform
  
  # AWS & Projeto
  aws_region    = var.aws_region
  project_name  = var.project_name
  environment   = var.environment
  
  # Configurações das Lambdas
  lambda_runtime                = var.lambda_runtime
  lambda_timeout_orchestrator   = var.lambda_timeout_orchestrator
  lambda_timeout_worker         = var.lambda_timeout_worker
  lambda_timeout_webhook        = var.lambda_timeout_webhook
  lambda_memory_size            = var.lambda_memory_size
  worker_reserved_concurrency   = var.worker_reserved_concurrency
  
  # SQS & Filas
  sqs_visibility_timeout     = var.sqs_visibility_timeout
  sqs_max_receive_count      = var.sqs_max_receive_count
  sqs_message_retention_days = var.sqs_message_retention_days
  
  # EventBridge
  eventbridge_schedule = var.eventbridge_schedule
  eventbridge_timezone = var.eventbridge_timezone
  
  # Banco de Dados
  database_type                  = var.database_type
  database_connection_secret_arn = var.database_connection_secret_arn
  
  # Asaas & Secrets
  asaas_api_base_url     = var.asaas_api_base_url
  asaas_token_secret_arn = var.asaas_token_secret_arn
  
  # Alertas & Monitoramento
  enable_cloudwatch_alarms = var.enable_cloudwatch_alarms
  sns_alert_topic_arn      = var.sns_alert_topic_arn
  
  # API Gateway Webhook
  enable_webhook_api     = var.enable_webhook_api
  webhook_api_stage_name = var.webhook_api_stage_name
  
  # ===========================
  # DIFERENÇAS CRÍTICAS PARA PROD
  # ===========================
  # Em produção, NÃO criamos secrets via Terraform
  # Eles devem ser criados manualmente ou via pipeline seguro
}

# ===========================
# Outputs
# ===========================
output "sqs_main_queue_url" {
  description = "URL da fila principal de cobranças"
  value       = module.cobranca_asaas.sqs_main_queue_url
}

output "sqs_dlq_arn" {
  description = "ARN da Dead Letter Queue"
  value       = module.cobranca_asaas.sqs_dlq_arn
}

output "lambda_worker_arn" {
  description = "ARN da Lambda Worker"
  value       = module.cobranca_asaas.lambda_worker_arn
}

output "lambda_orchestrator_arn" {
  description = "ARN da Lambda Orquestradora"
  value       = module.cobranca_asaas.lambda_orchestrator_arn
}

output "eventbridge_rule_arn" {
  description = "ARN da regra do EventBridge"
  value       = module.cobranca_asaas.eventbridge_rule_arn
}

output "webhook_api_invoke_url" {
  description = "URL de invoke da API Gateway para webhook"
  value       = module.cobranca_asaas.webhook_api_invoke_url
}

output "asaas_webhook_registration_payload" {
  description = "Payload JSON para registrar webhook no Asaas"
  value       = module.cobranca_asaas.asaas_webhook_registration_payload
}