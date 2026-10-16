output "app_server_instance_ids" {
  description = "IDs of the application EC2 instances"
  value       = module.compute.instance_ids
}

output "app_server_public_ips" {
  description = "Public IP addresses of the application EC2 instances"
  value       = module.compute.public_ips
}

output "app_server_private_ips" {
  description = "Private IP addresses of the application EC2 instances"
  value       = module.compute.private_ips
}

output "website_url" {
  description = "Web application URL"
  value       = module.webapp.website_url
}

output "website_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.webapp.dns_name
}

output "vpc_id" {
  description = "ID of the shared VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for the ALB and other public resources"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs for domain controllers, FSx and private workloads"
  value       = module.network.private_subnet_ids
}

output "domain_controller_instance_id" {
  description = "EC2 instance ID of the domain controller"
  value       = module.domain_controller.instance_id
}

output "domain_controller_private_ip" {
  description = "Private IP address of the domain controller and DNS server"
  value       = module.domain_controller.private_ip
}

output "fsx_id" {
  description = "Amazon FSx file-system ID"
  value       = module.fsx.file_system_id
}

output "fsx_dns_name" {
  description = "DNS name of the Amazon FSx file system"
  value       = module.fsx.dns_name
}

output "fsx_windows_share_path" {
  description = "Default Windows UNC path for the FSx file share"
  value       = module.fsx.windows_share_path
}