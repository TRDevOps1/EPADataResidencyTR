variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_controller_instance_id" {
  description = "Domain Controller EC2 instance ID"
  type        = string
}

variable "windows_instance_id" {
  description = "Windows EC2 instance ID"
  type        = string
}

variable "ubuntu_instance_id" {
  description = "Ubuntu EC2 instance ID"
  type        = string
}