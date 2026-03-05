# ===========================
# AWS & Projeto
# ===========================
aws_region     = "sa-east-1"
aws_access_key = "AKIAPROD1234567890"
aws_secret_key = "ProdSecretKeyExample12345678901234567890"
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
sqs_queue_name             = "cobranca-asaas-prod-pending"
sqs_visibility_timeout     = 60
sqs_max_receive_count      = 3
sqs_message_retention_days = 14

# ===========================
# EventBridge
# ===========================
eventbridge_schedule = "cron(0 9 * * ? *)"
eventbridge_timezone = "America/Sao_Paulo"

# ===========================
# Banco de Dados
# ===========================
database_type     = "postgresql"
database_host     = "cobranca-prod.xxx.sa-east-1.rds.amazonaws.com"
database_port     = 5432
database_name     = "cobranca"
database_user     = "admin"
database_password = "senha_prod_segura_aqui"

# ===========================
# Asaas (Produção)
# ===========================
asaas_api_base_url = "https://www.asaas.com/api/v3"
asaas_token        = "$aact_PRODUCTION_TOKEN_AQUI"

# ===========================
# API Gateway Webhook
# ===========================
enable_webhook_api     = true
webhook_api_stage_name = "prod"

# ===========================
# Alertas
# ===========================
enable_cloudwatch_alarms = true
sns_alert_topic_arn      = "arn:aws:sns:sa-east-1:123456789012:cobranca-asaas-prod-alerts"