output "instance_id" {
  description = "EC2 instance ID of the domain controller"
  value       = aws_instance.domain_controller.id
}

output "private_ip" {
  description = "Private IP address of the domain controller"
  value       = aws_instance.domain_controller.private_ip
}

output "dns_server_ips" {
  description = "DNS server addresses used by Active Directory clients"
  value = [
    aws_instance.domain_controller.private_ip
  ]

  depends_on = [
    time_sleep.wait_for_active_directory
  ]
}

output "security_group_id" {
  description = "Security group attached to the domain controller"
  value       = aws_security_group.domain_controller.id
}

output "domain_distinguished_name" {
  description = "Distinguished name of the Active Directory domain"
  value       = local.domain_distinguished_name
}

output "fsx_ou_distinguished_name" {
  description = "Distinguished name of the OU used by FSx"
  value       = local.fsx_ou_distinguished_name
}

output "active_directory_ready_dependency" {
  description = "Dependency representing the Active Directory bootstrap wait"
  value       = time_sleep.wait_for_active_directory.id
}