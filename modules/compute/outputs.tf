output "ubuntu_private_ip" {
  value = aws_instance.ubuntu.private_ip
}

output "windows_private_ip" {
  value = aws_instance.windows.private_ip
}

output "ubuntu_instance_id" {
  value = aws_instance.ubuntu.id
}

output "windows_instance_id" {
  value = aws_instance.windows.id
}