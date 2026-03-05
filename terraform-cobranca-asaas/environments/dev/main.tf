# Chama os módulos do root com configurações de dev
module "cobranca_asaas" {
  source = "../.." # Volta para a raiz do terraform
  
  environment = "dev"
  
  # Configurações específicas de dev
  lambda_timeout_orchestrator = 180 # Mais tempo para debug
  lambda_memory_size          = 256
  worker_reserved_concurrency = 2   # Rate limit baixo em dev
  
  # Secrets (em dev, criamos placeholders)
  database_connection_secret_arn = aws_secretsmanager_secret.db_connection[0].arn
  asaas_token_secret_arn         = aws_secretsmanager_secret.asaas_token[0].arn
  
  # Webhook em dev pode ser desabilitado se não tiver endpoint público
  enable_webhook_api = true
  
  # Alertas desabilitados em dev
  enable_cloudwatch_alarms = false
  
  # SNS null em dev
  sns_alert_topic_arn = null
}