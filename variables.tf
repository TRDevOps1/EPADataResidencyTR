variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "eu-west-2"
}

variable "instance_count" {
  description = "Number of application EC2 instances"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "windows-fsx-poc"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "poc"
}

variable "vpc_cidr" {
  description = "CIDR block allocated to the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "domain_name" {
  description = "Fully qualified Active Directory domain name"
  type        = string
  default     = "corp.example.com"
}

variable "domain_netbios_name" {
  description = "Active Directory NetBIOS domain name"
  type        = string
  default     = "CORP"
}

variable "domain_administrator_password" {
  description = "Password for the Active Directory domain administrator"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.domain_administrator_password) >= 12
    error_message = "The domain administrator password must contain at least 12 characters."
  }
}

variable "fsx_service_account_name" {
  description = "Domain service account used by FSx to join the domain"
  type        = string
  default     = "svc-fsx"
}

variable "fsx_service_account_password" {
  description = "Password for the FSx Active Directory service account"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.fsx_service_account_password) >= 12
    error_message = "The FSx service-account password must contain at least 12 characters."
  }
}

variable "allowed_management_cidr_blocks" {
  description = "CIDR ranges permitted to access the domain controller through RDP"
  type        = list(string)
  default     = []
}
