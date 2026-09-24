#output "website_url" {
#  value = "http://${aws_lb.web.dns_name}"
#}

output "dns_name" {
  value = aws_lb.web.dns_name
}
