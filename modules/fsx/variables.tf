variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC containing FSx"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by FSx"
  type        = list(string)
}

variable "domain_name" {
  description = "Fully qualified Active Directory domain name"
  type        = string
}

variable "domain_netbios_name" {
  description = "Active Directory NetBIOS domain name"
  type        = string
}

variable "dns_ips" {
  description = "IP addresses of the Active Directory DNS servers"
  type        = list(string)
}

variable "fsx_service_account_name" {
  description = "AD account used by FSx to join the domain"
  type        = string
}

variable "fsx_service_account_password" {
  description = "Password for the FSx Active Directory service account"
  type        = string
  sensitive   = true
}

variable "organizational_unit_distinguished_name" {
  description = "Active Directory OU into which the FSx computer object is created"
  type        = string
}

variable "domain_controller_security_group_id" {
  description = "Security group used by the domain controllers"
  type        = string
}

variable "deployment_type" {
  description = "FSx deployment type"
  type        = string
  default     = "SINGLE_AZ_2"

  validation {
    condition = contains(
      [
        "SINGLE_AZ_1",
        "SINGLE_AZ_2",
        "MULTI_AZ_1"
      ],
      var.deployment_type
    )

    error_message = "deployment_type must be SINGLE_AZ_1, SINGLE_AZ_2 or MULTI_AZ_1."
  }
}

variable "storage_capacity" {
  description = "FSx storage capacity in GiB"
  type        = number
  default     = 32
}

variable "storage_type" {
  description = "FSx storage type"
  type        = string
  default     = "SSD"
}

variable "throughput_capacity" {
  description = "FSx throughput capacity in MB/s"
  type        = number
  default     = 32
}

variable "automatic_backup_retention_days" {
  description = "Number of days automatic backups are retained"
  type        = number
  default     = 7
}

variable "skip_final_backup" {
  description = "Whether to omit the final backup when destroying FSx"
  type        = bool
  default     = true
}