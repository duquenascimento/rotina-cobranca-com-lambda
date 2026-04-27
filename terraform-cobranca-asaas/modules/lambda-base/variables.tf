variable "function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "filename" {
  description = "Caminho do arquivo ZIP com o código da Lambda"
  type        = string
}

variable "handler" {
  description = "Handler da função"
  type        = string
}

variable "runtime" {
  description = "Runtime da Lambda"
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Timeout em segundos"
  type        = number
  default     = 60
}

variable "memory_size" {
  description = "Memória em MB"
  type        = number
  default     = 512
}

variable "reserved_concurrency" {
  description = "Execuções concorrentes reservadas"
  type        = number
  default     = null
}

variable "environment" {
  description = "Ambiente (dev, prod)"
  type        = string
}

variable "environment_vars" {
  description = "Variáveis de ambiente"
  type        = map(string)
  default     = {}
}

variable "sqs_queue_arns" {
  description = "ARNs de filas SQS que a Lambda pode consumir"
  type        = list(string)
  default     = []
}

variable "additional_policy_statements" {
  description = "Statements adicionais para a política IAM"
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "event_source_arn" {
  description = "ARN da fonte de evento SQS para trigger automático"
  type        = string
  default     = null
}

variable "event_source_batch_size" {
  description = "Tamanho do batch para trigger SQS"
  type        = number
  default     = 10
}

variable "event_source_enabled" {
  description = "Habilitar trigger SQS"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}

variable "enable_sqs_trigger" {
  description = "Habilitar trigger SQS para esta Lambda (controla criação do recurso)"
  type        = bool
  default     = false
}

