# API Gateway HTTP API (mais simples e barato que REST)
resource "aws_apigatewayv2_api" "webhook" {
  count = var.enabled ? 1 : 0
  
  name          = var.api_name
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST"]
    allow_headers = ["*"]
  }
  
  tags = var.tags
}

resource "aws_apigatewayv2_stage" "webhook" {
  count = var.enabled ? 1 : 0
  
  api_id      = aws_apigatewayv2_api.webhook[0].id
  name        = var.stage_name
  auto_deploy = true
  
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
    format = jsonencode({
      requestId      = "$context.requestId"
      sourceIp       = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      protocol       = "$context.protocol"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      responseLength = "$context.responseLength"
    })
  }
  
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  count = var.enabled ? 1 : 0
  
  name              = "/aws/api-gateway/${var.api_name}"
  retention_in_days = 7
  
  tags = var.tags
}

# Rota POST /asaas-webhook
resource "aws_apigatewayv2_route" "webhook" {
  count = var.enabled ? 1 : 0
  
  api_id    = aws_apigatewayv2_api.webhook[0].id
  route_key = "POST /asaas-webhook"
  target    = "integrations/${aws_apigatewayv2_integration.webhook[0].id}"
}

resource "aws_apigatewayv2_integration" "webhook" {
  count = var.enabled ? 1 : 0
  
  api_id           = aws_apigatewayv2_api.webhook[0].id
  integration_type = "AWS_PROXY"
  
  integration_uri  = var.webhook_function_arn
  payload_format_version = "2.0"
}

# Permissão para API Gateway invocar Lambda
resource "aws_lambda_permission" "api_gateway" {
  count = var.enabled ? 1 : 0
  
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.webhook_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.webhook[0].execution_arn}/*/*"
  
  depends_on = [aws_apigatewayv2_integration.webhook]
}