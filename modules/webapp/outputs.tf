# modules/webapp/outputs.tf

output "website_url" {
  description = "Website URL"
  value       = "http://${aws_lb.web.dns_name}"
}

output "dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.web.dns_name
}