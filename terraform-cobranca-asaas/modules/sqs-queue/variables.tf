variable "queue_name" {
  description = "Nome da fila SQS principal"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout em segundos"
  type        = number
  default     = 60
}

variable "max_receive_count" {
  description = "Máximo de retries antes de enviar para DLQ"
  type        = number
  default     = 3
}

variable "message_retention_days" {
  description = "Dias de retenção da mensagem"
  type        = number
  default     = 14
}

variable "environment" {
  description = "Ambiente para tagging"
  type        = string
}

variable "enable_dlq_alarm" {
  description = "Habilitar alarme CloudWatch para DLQ"
  type        = bool
  default     = true
}

variable "sns_alert_topic_arn" {
  description = "ARN do SNS para notificações de alerta"
  type        = string
  default     = null
}