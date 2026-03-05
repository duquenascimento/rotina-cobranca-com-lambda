# Rule com scheduler (novo padrão)
resource "aws_scheduler_schedule" "main" {
  name       = var.rule_name
  group_name = "default"
  
  schedule_expression = "cron(${var.schedule_expression})"
  schedule_expression_timezone = var.timezone
  
  flexible_time_window {
    mode = "OFF"
  }
  
  target {
    arn      = var.target_function_arn
    role_arn = aws_iam_role.scheduler_target.arn
  }
  
  state = var.enabled ? "ENABLED" : "DISABLED"
  
  tags = var.tags
}

# IAM Role para o Scheduler invocar a Lambda
resource "aws_iam_role" "scheduler_target" {
  name = "${var.rule_name}-scheduler-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
    }]
  })
  
  tags = var.tags
}

resource "aws_iam_role_policy" "scheduler_target" {
  name = "${var.rule_name}-scheduler-policy"
  role = aws_iam_role.scheduler_target.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "lambda:InvokeFunction"
      Resource = var.target_function_arn
    }]
  })
}

# Permissão na Lambda para receber invoke do EventBridge Scheduler
resource "aws_lambda_permission" "allow_scheduler" {
  statement_id  = "AllowExecutionFromScheduler"
  action        = "lambda:InvokeFunction"
  function_name = var.target_function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.main.arn
}