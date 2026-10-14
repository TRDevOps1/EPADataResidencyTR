variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "poc"
}