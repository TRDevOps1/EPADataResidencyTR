variable "project_name" {
  description = "Name of the project"
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

variable "private_subnet_ids" {
  description = "IDs of the existing private subnets"
  type        = list(string)
}

variable "ubuntu_instance_type" {
  description = "Instance type for Ubuntu"
  type        = string
  default     = "t3.micro"
}

variable "windows_instance_type" {
  description = "Instance type for Windows"
  type        = string
  default     = "t3.micro"
}