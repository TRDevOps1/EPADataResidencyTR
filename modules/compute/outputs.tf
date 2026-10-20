output "ubuntu_instance_id" {
  description = "Instance ID of the Ubuntu server"
  value       = aws_instance.ubuntu.id
}

output "ubuntu_private_ip" {
  description = "Private IP address of the Ubuntu server"
  value       = aws_instance.ubuntu.private_ip
}

output "windows_member_instance_id" {
  description = "Instance ID of the Windows member server"
  value       = aws_instance.windows_member.id
}

output "windows_member_private_ip" {
  description = "Private IP address of the Windows member server"
  value       = aws_instance.windows_member.private_ip
}

output "compute_security_group_id" {
  description = "Security group used by the compute instances"
  value       = aws_security_group.compute.id
}