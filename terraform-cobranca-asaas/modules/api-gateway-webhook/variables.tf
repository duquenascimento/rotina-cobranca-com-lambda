variable "enabled" {
  description = "Habilitar criação da API Gateway"
  type        = bool
  default     = true
}

variable "api_name" {
  description = "Nome da API"
  type        = string
}

variable "stage_name" {
  description = "Nome do stage"
  type        = string
  default     = "prod"
}

variable "webhook_function_arn" {
  description = "ARN da Lambda que processa o webhook"
  type        = string
}

variable "webhook_function_name" {
  description = "Nome da Lambda para permissão"
  type        = string
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}