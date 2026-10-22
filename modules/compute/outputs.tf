output "ubuntu_instance_id" {
  description = "Ubuntu EC2 instance ID"
  value       = aws_instance.ubuntu.id
}

output "ubuntu_private_ip" {
  description = "Ubuntu private IP"
  value       = aws_instance.ubuntu.private_ip
}

output "windows_instance_id" {
  description = "Windows EC2 instance ID"
  value       = aws_instance.windows.id
}

output "windows_private_ip" {
  description = "Windows private IP"
  value       = aws_instance.windows.private_ip
}