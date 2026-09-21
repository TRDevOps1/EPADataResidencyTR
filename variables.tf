variable "aws_region" {
  description = "AWS region in which resources will be deployed"
  type        = string
  default     = "eu-central-2"
}

variable "instance_count" {
  description = "Number of application instances"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "tr-terraform-test159"
}
