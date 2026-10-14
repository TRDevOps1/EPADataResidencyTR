locals {
  name_prefix = "${var.project_name}-${var.environment}"

  domain_distinguished_name = join(
    ",",
    [
      for component in split(".", var.domain_name) :
      "DC=${component}"
    ]
  )

  fsx_ou_distinguished_name = "OU=FSx,${local.domain_distinguished_name}"
}

############################
# Windows Server AMI
############################

data "aws_ssm_parameter" "windows_server_2022" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

############################
# IAM role for SSM
############################

resource "aws_iam_role" "domain_controller" {
  name = "${local.name_prefix}-dc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.domain_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "domain_controller" {
  name = "${local.name_prefix}-dc-profile"
  role = aws_iam_role.domain_controller.name
}

############################
# Domain controller SG
############################

resource "aws_security_group" "domain_controller" {
  name        = "${local.name_prefix}-dc-sg"
  description = "Active Directory domain controller security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-dc-sg"
  }
}

# DNS TCP
resource "aws_vpc_security_group_ingress_rule" "dns_tcp" {
  security_group_id = aws_security_group.domain_controller.id

  description = "DNS TCP from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 53
  to_port     = 53
}

# DNS UDP
resource "aws_vpc_security_group_ingress_rule" "dns_udp" {
  security_group_id = aws_security_group.domain_controller.id

  description = "DNS UDP from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "udp"
  from_port   = 53
  to_port     = 53
}

# Kerberos TCP
resource "aws_vpc_security_group_ingress_rule" "kerberos_tcp" {
  security_group_id = aws_security_group.domain_controller.id

  description = "Kerberos TCP from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 88
  to_port     = 88
}

# Kerberos UDP
resource "aws_vpc_security_group_ingress_rule" "kerberos_udp" {
  security_group_id = aws_security_group.domain_controller.id

  description = "Kerberos UDP from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "udp"
  from_port   = 88
  to_port     = 88
}

# NTP
resource "aws_vpc_security_group_ingress_rule" "ntp" {
  security_group_id = aws_security_group.domain_controller.id

  description = "NTP from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "udp"
  from_port   = 123
  to_port     = 123
}

# RPC endpoint mapper
resource "aws_vpc_security_group_ingress_rule" "rpc_endpoint_mapper" {
  security_group_id = aws_security_group.domain_controller.id

  description = "RPC endpoint mapper from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 135
  to_port     = 135
}

# NetBIOS name service
resource "aws_vpc_security_group_ingress_rule" "netbios_name" {
  security_group_id = aws_security_group.domain_controller.id

  description = "NetBIOS name service from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "udp"
  from_port   = 137
  to_port     = 137
}

# NetBIOS datagram
resource "aws_vpc_security_group_ingress_rule" "netbios_datagram" {
  security_group_id = aws_security_group.domain_controller.id

  description = "NetBIOS datagram from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "udp"
  from_port   = 138
  to_port     = 138
}

# NetBIOS session
resource "aws_vpc_security_group_ingress_rule" "netbios_session" {
  security_group_id = aws_security_group.domain_controller.id

  description = "NetBIOS session from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 139
  to_port     = 139
}

# LDAP TCP
resource "aws_vpc_security_group_ingress_rule" "ldap_tcp" {
  security_group_id = aws_security_group.domain_controller.id

  description = "LDAP TCP from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 389
  to_port     = 389
}

# LDAP UDP
resource "aws_vpc_security_group_ingress_rule" "ldap_udp" {
  security_group_id = aws_security_group.domain_controller.id

  description = "LDAP UDP from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "udp"
  from_port   = 389
  to_port     = 389
}

# SMB
resource "aws_vpc_security_group_ingress_rule" "smb" {
  security_group_id = aws_security_group.domain_controller.id

  description = "SMB from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 445
  to_port     = 445
}

# Kerberos password change
resource "aws_vpc_security_group_ingress_rule" "kerberos_password_tcp" {
  security_group_id = aws_security_group.domain_controller.id

  description = "Kerberos password TCP from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 464
  to_port     = 464
}

resource "aws_vpc_security_group_ingress_rule" "kerberos_password_udp" {
  security_group_id = aws_security_group.domain_controller.id

  description = "Kerberos password UDP from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "udp"
  from_port   = 464
  to_port     = 464
}

# LDAPS
resource "aws_vpc_security_group_ingress_rule" "ldaps" {
  security_group_id = aws_security_group.domain_controller.id

  description = "LDAPS from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 636
  to_port     = 636
}

# Global Catalog
resource "aws_vpc_security_group_ingress_rule" "global_catalog" {
  security_group_id = aws_security_group.domain_controller.id

  description = "Global Catalog from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 3268
  to_port     = 3269
}

# Dynamic RPC
resource "aws_vpc_security_group_ingress_rule" "dynamic_rpc" {
  security_group_id = aws_security_group.domain_controller.id

  description = "Dynamic RPC from VPC"
  cidr_ipv4   = var.vpc_cidr

  ip_protocol = "tcp"
  from_port   = 49152
  to_port     = 65535
}

# Optional RDP
resource "aws_vpc_security_group_ingress_rule" "rdp" {
  for_each = toset(var.allowed_management_cidr_blocks)

  security_group_id = aws_security_group.domain_controller.id

  description = "RDP from approved management range"
  cidr_ipv4   = each.value

  ip_protocol = "tcp"
  from_port   = 3389
  to_port     = 3389
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.domain_controller.id

  description = "Outbound connectivity"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

############################
# Domain controller
############################

resource "aws_instance" "domain_controller" {
  ami           = data.aws_ssm_parameter.windows_server_2022.value
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  private_ip                  = var.private_ip
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.domain_controller.id
  ]

  iam_instance_profile = aws_iam_instance_profile.domain_controller.name

  user_data = templatefile(
    "${path.module}/userdata.ps1.tftpl",
    {
      domain_name                   = var.domain_name
      domain_netbios_name           = var.domain_netbios_name
      domain_administrator_password = var.domain_administrator_password
      fsx_service_account_name      = var.fsx_service_account_name
      fsx_service_account_password  = var.fsx_service_account_password
      fsx_ou_distinguished_name     = local.fsx_ou_distinguished_name
    }
  )

  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm
  ]

  tags = {
    Name = "${local.name_prefix}-dc01"
    Role = "ActiveDirectoryDomainController"
  }

  lifecycle {
    precondition {
      condition     = can(regex("^[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.domain_name))
      error_message = "domain_name must be a fully qualified domain name."
    }
  }
}

############################
# Wait for Windows promotion
############################

resource "time_sleep" "wait_for_active_directory" {
  create_duration = "12m"

  depends_on = [
    aws_instance.domain_controller
  ]
}