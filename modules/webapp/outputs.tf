output "website_url" {
  value = "http://${aws_lb.web.dns_name}"
}