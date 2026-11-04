output "dashboard_name" {
  description = "Name of the CloudWatch infrastructure dashboard"
  value       = aws_cloudwatch_dashboard.infrastructure.dashboard_name
}

output "webpage_canary_name" {
  description = "Name of the CloudWatch Synthetics webpage canary"
  value       = aws_synthetics_canary.webpage_uptime.name
}

output "webpage_uptime_alarm_name" {
  description = "Name of the webpage availability alarm"
  value       = aws_cloudwatch_metric_alarm.webpage_uptime.alarm_name
}

output "synthetics_artifact_bucket_name" {
  description = "S3 bucket containing CloudWatch Synthetics artifacts"
  value       = aws_s3_bucket.synthetics_artifacts.id
}