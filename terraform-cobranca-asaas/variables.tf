# ===========================
# AWS & Projeto
# ===========================
variable "aws_region" {
  description = "Região da AWS"
  type        = string
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Nome do projeto para tagging"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, prod)"
  type        = string
}

# ===========================
# Configurações das Lambdas
# ===========================
variable "lambda_runtime" {
  description = "Runtime das Lambdas"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout_orchestrator" {
  description = "Timeout da Lambda Orquestradora (segundos)"
  type        = number
  default     = 120
}

variable "lambda_timeout_worker" {
  description = "Timeout da Lambda Worker (segundos)"
  type        = number
  default     = 60
}

variable "lambda_timeout_webhook" {
  description = "Timeout da Lambda Webhook (segundos)"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Memória das Lambdas (MB)"
  type        = number
  default     = 512
}

variable "worker_reserved_concurrency" {
  description = "Concorrência reservada da Worker"
  type        = number
  default     = 10
}

# ===========================
# SQS & Filas
# ===========================
variable "sqs_queue_name" {
  description = "Nome da fila SQS principal"
  type        = string
}

variable "sqs_visibility_timeout" {
  description = "Visibility timeout da SQS (segundos)"
  type        = number
  default     = 60
}

variable "sqs_max_receive_count" {
  description = "Máximo de retries antes de DLQ"
  type        = number
  default     = 3
}

variable "sqs_message_retention_days" {
  description = "Retenção de mensagens na fila (dias)"
  type        = number
  default     = 14
}

# ===========================
# EventBridge
# ===========================
variable "eventbridge_schedule" {
  description = "Expressão cron para disparo"
  type        = string
}

variable "eventbridge_timezone" {
  description = "Timezone do EventBridge"
  type        = string
  default     = "America/Sao_Paulo"
}

# ===========================
# Banco de Dados
# ===========================
variable "database_type" {
  description = "Tipo de banco: postgresql ou dynamodb"
  type        = string
}

variable "database_host" {
  description = "Host do banco de dados"
  type        = string
}

variable "database_port" {
  description = "Porta do banco de dados"
  type        = number
}

variable "database_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "database_user" {
  description = "Usuário do banco de dados"
  type        = string
}

variable "database_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

# ===========================
# Asaas
# ===========================
variable "asaas_api_base_url" {
  description = "URL base da API do Asaas"
  type        = string
}

variable "asaas_token" {
  description = "Token de acesso da API Asaas"
  type        = string
  sensitive   = true
}

# ===========================
# API Gateway Webhook
# ===========================
variable "enable_webhook_api" {
  description = "Habilitar API Gateway para webhook"
  type        = bool
  default     = true
}

variable "webhook_api_stage_name" {
  description = "Nome do stage da API Gateway"
  type        = string
  default     = "prod"
}

# ===========================
# Alertas
# ===========================
variable "enable_cloudwatch_alarms" {
  description = "Habilitar alarmes CloudWatch"
  type        = bool
  default     = true
}

variable "sns_alert_topic_arn" {
  description = "ARN do SNS para alertas"
  type        = string
  default     = null
}