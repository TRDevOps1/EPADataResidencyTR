output "file_system_id" {
  description = "ID of the FSx file system"
  value       = aws_fsx_windows_file_system.main.id
}

output "arn" {
  description = "ARN of the FSx file system"
  value       = aws_fsx_windows_file_system.main.arn
}

output "dns_name" {
  description = "DNS name of the FSx file system"
  value       = aws_fsx_windows_file_system.main.dns_name
}

output "windows_share_path" {
  description = "Default Windows UNC path for the FSx file share"
  value       = "\\\\${aws_fsx_windows_file_system.main.dns_name}\\share"
}

output "security_group_id" {
  description = "Security group attached to FSx"
  value       = aws_security_group.fsx.id
}

output "network_interface_ids" {
  description = "FSx network-interface IDs"
  value       = aws_fsx_windows_file_system.main.network_interface_ids
}