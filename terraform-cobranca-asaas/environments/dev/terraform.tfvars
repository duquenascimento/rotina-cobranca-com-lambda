# ===========================
# AWS & Projeto
# ===========================
aws_region     = "sa-east-1"
project_name   = "cobranca-asaas"
environment    = "prod"

# ===========================
# Configurações das Lambdas
# ===========================
lambda_runtime                = "python3.11"
lambda_timeout_orchestrator   = 120
lambda_timeout_worker         = 60
lambda_timeout_webhook        = 30
lambda_memory_size            = 512
worker_reserved_concurrency   = 10

# ===========================
# SQS & Filas
# ===========================
sqs_visibility_timeout     = 60
sqs_max_receive_count      = 3
sqs_message_retention_days = 14

# ===========================
# EventBridge
# ===========================
# Todo dia às 6h BRT (9h UTC) - horário de produção
eventbridge_schedule = "cron(0 9 * * ? *)"
eventbridge_timezone = "America/Sao_Paulo"

# ===========================
# Banco de Dados
# ===========================
database_type = "postgresql"

# Preencher com ARN real do Secrets Manager em produção
database_connection_secret_arn = "arn:aws:secretsmanager:sa-east-1:123456789012:secret:cobranca-asaas-prod/database/connection-xxxxxx"

# ===========================
# Asaas & Secrets
# ===========================
# API de Produção do Asaas
asaas_api_base_url = "https://www.asaas.com/api/v3"

# Preencher com ARN real do Secrets Manager em produção
asaas_token_secret_arn = "arn:aws:secretsmanager:sa-east-1:123456789012:secret:cobranca-asaas-prod/asaas/token-xxxxxx"

# ===========================
# Alertas & Monitoramento
# ===========================
enable_cloudwatch_alarms = true
sns_alert_topic_arn      = "arn:aws:sns:sa-east-1:123456789012:cobranca-asaas-prod-alerts"

# ===========================
# API Gateway Webhook
# ===========================
enable_webhook_api     = true
webhook_api_stage_name = "prod"

# ===========================
# Backend S3
# ===========================
terraform_backend_bucket         = "my-company-tfstate-prod"
terraform_backend_dynamodb_table = "my-company-tfstate-lock"