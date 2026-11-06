output "dashboard_name" {
  description = "Name of the CloudWatch infrastructure dashboard"
  value       = aws_cloudwatch_dashboard.infrastructure.dashboard_name
}

output "webpage_uptime_alarm_name" {
  description = "Name of the webpage availability alarm"
  value       = aws_cloudwatch_metric_alarm.webpage_uptime.alarm_name
}

