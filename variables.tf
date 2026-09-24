variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "instance_count" {
  description = "Number of application EC2 instances"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}


