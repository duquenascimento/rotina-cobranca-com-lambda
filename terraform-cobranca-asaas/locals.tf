locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  # Nomes padronizados dos recursos
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Filas SQS
  sqs_queue_name          = "${local.resource_prefix}-cobrancas-pending"
  sqs_dlq_name            = "${local.resource_prefix}-cobrancas-dlq"
  
  # Lambdas
  lambda_orchestrator_name = "${local.resource_prefix}-orchestrator"
  lambda_worker_name       = "${local.resource_prefix}-worker"
  lambda_webhook_name      = "${local.resource_prefix}-webhook-handler"
  
  # EventBridge
  eventbridge_rule_name = "${local.resource_prefix}-daily-trigger"
  
  # API Gateway
  api_gateway_name = "${local.resource_prefix}-webhook-api"
  
  # Paths do código das Lambdas (para empacotamento)
  lambda_source_paths = {
    orchestrator = "${path.module}/lambdas/orchestrator"
    worker       = "${path.module}/lambdas/worker"
    webhook      = "${path.module}/lambdas/webhook_handler"
  }
}