###############################################################################
# Ubuntu AMI
###############################################################################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

###############################################################################
# Windows Server 2022 AMI
###############################################################################

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["801119661308"]

  filter {
    name = "name"

    values = [
      "Windows_Server-2022-English-Full-Base-*"
    ]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

###############################################################################
# Existing domain-join secret
###############################################################################

data "aws_secretsmanager_secret" "domain_join" {
  arn = var.domain_join_secret_arn
}

###############################################################################
# EC2 IAM role
###############################################################################

resource "aws_iam_role" "compute" {
  name = "${var.project_name}-${var.environment}-compute-role"

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

  tags = var.tags
}

###############################################################################
# Systems Manager access
###############################################################################

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.compute.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

###############################################################################
# Secrets Manager access
###############################################################################

resource "aws_iam_role_policy" "domain_join_secret" {
  name = "${var.project_name}-${var.environment}-domain-join-secret"
  role = aws_iam_role.compute.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadDomainJoinSecret"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = data.aws_secretsmanager_secret.domain_join.arn
      }
    ]
  })
}

###############################################################################
# Instance profile
###############################################################################

resource "aws_iam_instance_profile" "compute" {
  name = "${var.project_name}-${var.environment}-compute-profile"
  role = aws_iam_role.compute.name
}

###############################################################################
# Compute security group
###############################################################################

resource "aws_security_group" "compute" {
  name_prefix = "${var.project_name}-${var.environment}-compute-"
  description = "Security group for Ubuntu and Windows member servers"
  vpc_id      = var.vpc_id

  # No inbound SSH or RDP is required because SSM is used for management.

  egress {
    description = "Allow outbound connectivity"

    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-compute-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# Ubuntu server
###############################################################################

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ubuntu_instance_type

  subnet_id = var.private_subnet_id

  vpc_security_group_ids = [
    aws_security_group.compute.id
  ]

  iam_instance_profile = aws_iam_instance_profile.compute.name

  associate_public_ip_address = false

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.ubuntu_root_volume_size

    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ubuntu"
      OS   = "Ubuntu 24.04"
      Role = "Application Server"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.ssm
  ]
}

###############################################################################
# Windows member server
###############################################################################

resource "aws_instance" "windows_member" {
  ami           = data.aws_ami.windows.id
  instance_type = var.windows_instance_type

  subnet_id = var.private_subnet_id

  vpc_security_group_ids = [
    aws_security_group.compute.id
  ]

  iam_instance_profile = aws_iam_instance_profile.compute.name

  associate_public_ip_address = false

  user_data = templatefile(
    "${path.module}/templates/windows-member-userdata.ps1.tftpl",
    {
      aws_region             = var.aws_region
      computer_name          = var.windows_computer_name
      domain_name            = var.domain_name
      domain_join_secret_arn = var.domain_join_secret_arn
      domain_ou_path         = var.domain_ou_path

      primary_dns_server = (
        var.domain_controller_private_ips[0]
      )

      secondary_dns_server = (
        length(var.domain_controller_private_ips) > 1
        ? var.domain_controller_private_ips[1]
        : var.domain_controller_private_ips[0]
      )
    }
  )

  # Replaces the instance if the domain-join bootstrap configuration changes.
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.windows_root_volume_size

    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-windows-member"
      OS   = "Windows Server 2022"
      Role = "Domain Member Server"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.ssm,
    aws_iam_role_policy.domain_join_secret
  ]
}