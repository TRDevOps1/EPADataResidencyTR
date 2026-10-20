output "ubuntu_instance_id" {
  description = "Ubuntu EC2 instance ID"
  value       = aws_instance.ubuntu.id
}

output "ubuntu_private_ip" {
  description = "Ubuntu private IP address"
  value       = aws_instance.ubuntu.private_ip
}

output "windows_member_instance_id" {
  description = "Windows member server EC2 instance ID"
  value       = aws_instance.windows_member.id
}

output "windows_member_private_ip" {
  description = "Windows member server private IP address"
  value       = aws_instance.windows_member.private_ip
}

output "compute_security_group_id" {
  description = "Security group used by the compute instances"
  value       = aws_security_group.compute.id
}