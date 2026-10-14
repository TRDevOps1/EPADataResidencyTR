locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

############################
# FSx security group
############################

resource "aws_security_group" "fsx" {
  name        = "${local.name_prefix}-fsx-sg"
  description = "Security group for Amazon FSx for Windows File Server"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-fsx-sg"
  }
}

# Allow SMB from members of the DC security group.
# Add other client/application security groups here when required.
resource "aws_vpc_security_group_ingress_rule" "smb_from_domain" {
  security_group_id = aws_security_group.fsx.id

  description                  = "SMB from domain-connected systems"
  referenced_security_group_id = var.domain_controller_security_group_id

  ip_protocol = "tcp"
  from_port   = 445
  to_port     = 445
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.fsx.id

  description = "Outbound access for AD, DNS and AWS services"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

############################
# FSx for Windows
############################

resource "aws_fsx_windows_file_system" "main" {
  storage_capacity    = var.storage_capacity
  storage_type        = var.storage_type
  throughput_capacity = var.throughput_capacity

  deployment_type = var.deployment_type
  subnet_ids      = var.subnet_ids

  security_group_ids = [
    aws_security_group.fsx.id
  ]

  automatic_backup_retention_days   = var.automatic_backup_retention_days
  daily_automatic_backup_start_time = "01:00"
  weekly_maintenance_start_time     = "7:03:00"

  copy_tags_to_backups = true
  skip_final_backup    = var.skip_final_backup

  self_managed_active_directory {
    domain_name = var.domain_name

    dns_ips = var.dns_ips

    username = var.fsx_service_account_name
    password = var.fsx_service_account_password

    organizational_unit_distinguished_name = (
      var.organizational_unit_distinguished_name
    )

    file_system_administrators_group = "Domain Admins"
  }

  tags = {
    Name = "${local.name_prefix}-fsx"
  }

  lifecycle {
    precondition {
      condition = (
        var.deployment_type == "MULTI_AZ_1"
        ? length(var.subnet_ids) == 2
        : length(var.subnet_ids) == 1
      )

      error_message = "MULTI_AZ_1 requires two subnets; Single-AZ requires one subnet."
    }

    precondition {
      condition     = length(var.dns_ips) >= 1 && length(var.dns_ips) <= 2
      error_message = "Provide one or two Active Directory DNS server IP addresses."
    }
  }
}