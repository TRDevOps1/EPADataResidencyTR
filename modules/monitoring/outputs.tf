output "dashboard_name" {
  description = "Name of the CloudWatch infrastructure dashboard"
  value       = aws_cloudwatch_dashboard.infrastructure.dashboard_name
}

