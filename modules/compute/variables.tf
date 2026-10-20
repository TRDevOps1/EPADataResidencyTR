variable "aws_region" {
  description = "AWS region containing the infrastructure"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the compute security group"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet used by the domain controller and compute servers"
  type        = string
}

variable "ubuntu_instance_type" {
  description = "EC2 instance type for the Ubuntu server"
  type        = string
  default     = "t3.micro"
}

variable "windows_instance_type" {
  description = "EC2 instance type for the Windows member server"
  type        = string
  default     = "t3.medium"
}

variable "ubuntu_root_volume_size" {
  description = "Ubuntu root volume size in GiB"
  type        = number
  default     = 20

  validation {
    condition     = var.ubuntu_root_volume_size >= 8
    error_message = "The Ubuntu root volume must be at least 8 GiB."
  }
}

variable "windows_root_volume_size" {
  description = "Windows root volume size in GiB"
  type        = number
  default     = 50

  validation {
    condition     = var.windows_root_volume_size >= 30
    error_message = "The Windows root volume must be at least 30 GiB."
  }
}

variable "windows_computer_name" {
  description = "Windows computer name, limited to 15 characters"
  type        = string
  default     = "APP-MEMBER-01"

  validation {
    condition = (
      length(var.windows_computer_name) >= 1 &&
      length(var.windows_computer_name) <= 15 &&
      can(regex("^[A-Za-z0-9-]+$", var.windows_computer_name))
    )

    error_message = "The Windows computer name must contain 1-15 letters, numbers or hyphens."
  }
}

variable "domain_name" {
  description = "DNS name of the existing Active Directory domain"
  type        = string
}

variable "domain_controller_private_ips" {
  description = "Private IP addresses used for Active Directory DNS"
  type        = list(string)

  validation {
    condition     = length(var.domain_controller_private_ips) >= 1
    error_message = "At least one domain controller IP address must be supplied."
  }
}

variable "domain_join_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the domain credentials"
  type        = string
}

variable "domain_ou_path" {
  description = "Optional distinguished name for the member-server OU"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for compute resources"
  type        = map(string)
  default     = {}
}