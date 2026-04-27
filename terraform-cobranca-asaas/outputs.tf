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