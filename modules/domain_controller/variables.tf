variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC containing the domain controller"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet used by the domain controller"
  type        = string
}

variable "private_ip" {
  description = "Static private IP assigned to the domain controller"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the domain controller"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Size of the domain controller root disk in GiB"
  type        = number
  default     = 50
}

variable "domain_name" {
  description = "Fully qualified Active Directory domain name"
  type        = string
}

variable "domain_netbios_name" {
  description = "Active Directory NetBIOS domain name"
  type        = string
}

variable "domain_administrator_password" {
  description = "Active Directory domain administrator password"
  type        = string
  sensitive   = true
}

variable "fsx_service_account_name" {
  description = "Domain service account that FSx uses to join the domain"
  type        = string
  default     = "svc-fsx"
}

variable "fsx_service_account_password" {
  description = "Password for the FSx domain service account"
  type        = string
  sensitive   = true
}

variable "allowed_management_cidr_blocks" {
  description = "CIDR ranges permitted to use RDP"
  type        = list(string)
  default     = []
}