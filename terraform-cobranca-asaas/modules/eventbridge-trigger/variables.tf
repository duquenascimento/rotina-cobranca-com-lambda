variable "rule_name" {
  description = "Nome da regra do EventBridge"
  type        = string
}

variable "schedule_expression" {
  description = "Expressão cron ou rate"
  type        = string
}

variable "timezone" {
  description = "Timezone para a expressão cron"
  type        = string
  default     = "UTC"
}

variable "target_function_arn" {
  description = "ARN da Lambda alvo"
  type        = string
}

variable "target_function_name" {
  description = "Nome da Lambda alvo para permissão"
  type        = string
}

variable "enabled" {
  description = "Habilitar a regra"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}