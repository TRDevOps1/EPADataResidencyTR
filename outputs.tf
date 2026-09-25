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

output "s3_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = module.storage.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the application S3 bucket"
  value       = module.storage.bucket_arn
}

output "website_url" {
  description = "Web application URL"
  value = module.webapp.website_url
}

output "website_dns_name" {
  description = "Application Load Balancer DNS name"
  value = module.webapp.dns_name
}