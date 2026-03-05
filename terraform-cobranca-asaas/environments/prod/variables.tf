# ===========================
# AWS & Projeto
# ===========================
variable "aws_region" {
  description = "Região da AWS para ambiente prod"
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Nome do projeto para tagging"
  type        = string
  default     = "cobranca-asaas"
}

variable "environment" {
  description = "Ambiente (fixo para prod)"
  type        = string
  default     = "prod"
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
  description = "Concorrência reservada da Worker (rate limiting Asaas)"
  type        = number
  default     = 10
}

# ===========================
# SQS & Filas
# ===========================
variable "sqs_visibility_timeout" {
  description = "Visibility timeout da SQS (segundos)"
  type        = number
  default     = 60
}

variable "sqs_max_receive_count" {
  description = "Máximo de tentativas antes de enviar para DLQ"
  type        = number
  default     = 3
}

variable "sqs_message_retention_days" {
  description = "Tempo de retenção das mensagens na fila (dias)"
  type        = number
  default     = 14
}

# ===========================
# EventBridge
# ===========================
variable "eventbridge_schedule" {
  description = "Expressão cron para disparo da rotina"
  type        = string
  default     = "cron(0 9 * * ? *)"
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
  default     = "postgresql"
}

variable "database_connection_secret_arn" {
  description = "ARN do Secrets Manager com string de conexão do DB"
  type        = string
}

# ===========================
# Asaas & Secrets
# ===========================
variable "asaas_api_base_url" {
  description = "URL base da API do Asaas"
  type        = string
  default     = "https://www.asaas.com/api/v3"
}

variable "asaas_token_secret_arn" {
  description = "ARN do Secrets Manager com token da API Asaas"
  type        = string
}

# ===========================
# Alertas & Monitoramento
# ===========================
variable "enable_cloudwatch_alarms" {
  description = "Habilitar alarmes do CloudWatch para DLQ"
  type        = bool
  default     = true
}

variable "sns_alert_topic_arn" {
  description = "ARN do tópico SNS para alertas"
  type        = string
}

# ===========================
# API Gateway Webhook
# ===========================
variable "enable_webhook_api" {
  description = "Habilitar API Gateway para receber webhook do Asaas"
  type        = bool
  default     = true
}

variable "webhook_api_stage_name" {
  description = "Nome do stage da API Gateway"
  type        = string
  default     = "prod"
}

# ===========================
# Backend S3
# ===========================
variable "terraform_backend_bucket" {
  description = "Bucket S3 para estado do Terraform"
  type        = string
}

variable "terraform_backend_dynamodb_table" {
  description = "Tabela DynamoDB para locking do estado"
  type        = string
}