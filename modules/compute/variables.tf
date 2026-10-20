variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet used by the domain controllers"
  type        = string
}

variable "ubuntu_instance_type" {
  description = "EC2 instance type for Ubuntu"
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
}

variable "windows_root_volume_size" {
  description = "Windows root volume size in GiB"
  type        = number
  default     = 50
}

variable "windows_computer_name" {
  description = "Windows computer name, maximum 15 characters"
  type        = string
  default     = "APP-MEMBER-01"

  validation {
    condition = (
      length(var.windows_computer_name) >= 1 &&
      length(var.windows_computer_name) <= 15 &&
      can(regex("^[A-Za-z0-9-]+$", var.windows_computer_name))
    )

    error_message = "windows_computer_name must be 1-15 characters and contain only letters, numbers and hyphens."
  }
}

variable "domain_name" {
  description = "Existing Active Directory domain DNS name"
  type        = string
}

variable "domain_controller_private_ips" {
  description = "Private IP addresses of the domain controllers"
  type        = list(string)

  validation {
    condition     = length(var.domain_controller_private_ips) >= 1
    error_message = "At least one domain controller private IP must be supplied."
  }
}

variable "domain_join_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the domain join credentials"
  type        = string
  sensitive   = true
}

variable "domain_ou_path" {
  description = "Optional distinguished name of the OU for the member server"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}