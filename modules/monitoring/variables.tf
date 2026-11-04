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

variable "webpage_url" {
  description = "Full URL of the webpage monitored by CloudWatch Synthetics"
  type        = string

  validation {
    condition = (
      startswith(var.webpage_url, "http://") ||
      startswith(var.webpage_url, "https://")
    )

    error_message = "webpage_url must start with http:// or https://."
  }
}

variable "canary_runtime_version" {
  description = "CloudWatch Synthetics runtime used by the webpage canary"
  type        = string
  default     = "syn-nodejs-puppeteer-18.0"
}

variable "canary_artifact_retention_days" {
  description = "Number of days to retain canary S3 artifacts"
  type        = number
  default     = 30
}

variable "canary_success_retention_days" {
  description = "Number of days to retain successful canary run records"
  type        = number
  default     = 7
}

variable "canary_failure_retention_days" {
  description = "Number of days to retain failed canary run records"
  type        = number
  default     = 30
}