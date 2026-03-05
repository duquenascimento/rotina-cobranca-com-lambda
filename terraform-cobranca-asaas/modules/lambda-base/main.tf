# IAM Role
resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  
  tags = var.tags
}

# Política básica de logs
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política para acessar SQS (se necessário)
resource "aws_iam_policy" "sqs_access" {
  count = length(var.sqs_queue_arns) > 0 ? 1 : 0
  
  name = "${var.function_name}-sqs-access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ]
      Resource = var.sqs_queue_arns
    }]
  })
  
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sqs_access" {
  count = length(var.sqs_queue_arns) > 0 ? 1 : 0
  
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.sqs_access[0].arn
}

# Política para acessar Secrets Manager
resource "aws_iam_policy" "secrets_access" {
  count = length(var.secret_arns) > 0 ? 1 : 0
  
  name = "${var.function_name}-secrets-access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue"]
      Resource = var.secret_arns
    }]
  })
  
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  count = length(var.secret_arns) > 0 ? 1 : 0
  
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.secrets_access[0].arn
}

# Políticas adicionais customizadas
resource "aws_iam_role_policy" "additional" {
  count = length(var.additional_policy_statements) > 0 ? 1 : 0
  
  name = "${var.function_name}-additional"
  role = aws_iam_role.lambda.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for stmt in var.additional_policy_statements : {
        Effect   = stmt.effect
        Action   = stmt.actions
        Resource = stmt.resources
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "main" {
  filename         = var.filename
  function_name    = var.function_name
  role            = aws_iam_role.lambda.arn
  handler         = var.handler
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size
  publish         = true
  
  dynamic "reserved_concurrency" {
    for_each = var.reserved_concurrency != null ? [1] : []
    content {
      reserved_concurrent_executions = var.reserved_concurrency
    }
  }
  
  environment {
    variables = var.environment_vars
  }
  
  # Hash para re-deploy quando o código mudar
  source_code_hash = filebase64sha256(var.filename)
  
  tags = var.tags
  
  depends_on = [
    aws_iam_role_policy_attachment.basic_execution,
    aws_iam_role_policy_attachment.sqs_access,
    aws_iam_role_policy_attachment.secrets_access,
    aws_iam_role_policy.additional
  ]
}

# Log Group com retenção configurada
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.environment == "prod" ? 30 : 7
  
  tags = var.tags
}

# Trigger SQS -> Lambda (opcional)
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  count = var.event_source_arn != null && var.event_source_enabled ? 1 : 0
  
  event_source_arn                   = var.event_source_arn
  function_name                      = aws_lambda_function.main.arn
  enabled                           = var.event_source_enabled
  batch_size                        = var.event_source_batch_size
  maximum_batching_window_in_seconds = 5
  
  # Configurações de retry
  maximum_retry_attempts = 2
  bisect_batch_on_function_error = true
  
  dynamic "destination_config" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      on_failure {
        # Em prod, falhas vão para DLQ configurada na própria SQS
      }
    }
  }
}