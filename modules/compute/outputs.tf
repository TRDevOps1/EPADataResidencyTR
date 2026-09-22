modules/compute/outputs.tf
output "instance_ids" {
  description = "IDs of the application EC2 instances"
  value       = aws_instance.app_server[*].id
}

output "public_ips" {
  description = "Public IP addresses of the application EC2 instances"
  value       = aws_instance.app_server[*].public_ip
}

output "private_ips" {
  description = "Private IP addresses of the application EC2 instances"
  value       = aws_instance.app_server[*].private_ip
}
