output "app_server_public_ips" {
  description = "Public IP addresses of the application servers"
  value       = aws_instance.app_server[*].public_ip
}

output "s3_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = aws_s3_bucket.s3.bucket
}
