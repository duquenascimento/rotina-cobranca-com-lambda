output "rule_arn" {
  value = aws_scheduler_schedule.main.arn
}

output "rule_name" {
  value = aws_scheduler_schedule.main.name
}