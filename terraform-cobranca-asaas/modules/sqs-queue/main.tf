locals {
  message_retention_seconds = var.message_retention_days * 24 * 60 * 60
}

# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.queue_name}-dlq"
  message_retention_seconds = local.message_retention_seconds
  
  tags = {
    Name        = "${var.queue_name}-dlq"
    Environment = var.environment
  }
}

# Main Queue
resource "aws_sqs_queue" "main" {
  name                       = var.queue_name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = local.message_retention_seconds
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })
  
  tags = {
    Name        = var.queue_name
    Environment = var.environment
  }
}

# Alarme CloudWatch para DLQ
resource "aws_cloudwatch_metric_alarm" "dlq_has_messages" {
  count = var.enable_dlq_alarm ? 1 : 0
  
  alarm_name          = "${var.queue_name}-dlq-has-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alerta: Existem mensagens na DLQ da fila ${var.queue_name}"
  
  alarm_actions = var.sns_alert_topic_arn != null ? [var.sns_alert_topic_arn] : []
  
  dimensions = {
    QueueName = var.queue_name
  }
  
  tags = {
    Environment = var.environment
  }
}