variable "vpc_id" {
  description = "ID of the shared VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB and ECS service"
  type        = list(string)
}