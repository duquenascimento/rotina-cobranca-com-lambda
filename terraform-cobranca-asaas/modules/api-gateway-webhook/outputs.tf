output "api_id" {
  value = var.enabled ? aws_apigatewayv2_api.webhook[0].id : null
}

output "invoke_url" {
  value = var.enabled ? aws_apigatewayv2_stage.webhook[0].invoke_url : null
}

output "stage_name" {
  value = var.stage_name
}