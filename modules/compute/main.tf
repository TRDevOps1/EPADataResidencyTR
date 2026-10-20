###############################################################################
# AMIs
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
}

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
}

###############################################################################
# Secrets Manager
###############################################################################

data "aws_secretsmanager_secret" "domain_join" {
  arn = var.domain_join_secret_arn
}

###############################################################################
# IAM role for EC2 Systems Manager and Secrets Manager access
###############################################################################

resource "aws_iam_role" "ec2" {
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

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "domain_join_secret" {
  name = "${var.project_name}-${var.environment}-domain-join-secret"
  role = aws_iam_role.ec2.id

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

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-compute-profile"
  role = aws_iam_role.ec2.name
}

###############################################################################
# Security group
###############################################################################

resource "aws_security_group" "compute" {
  name        = "${var.project_name}-${var.environment}-compute-sg"
  description = "Security group for Ubuntu and Windows member servers"
  vpc_id      = var.vpc_id

  # No inbound SSH or RDP is required when using SSM.
  egress {
    description = "Allow outbound traffic"
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
}

###############################################################################
# Ubuntu server
###############################################################################

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ubuntu_instance_type
  subnet_id     = var.private_subnet_id

  vpc_security_group_ids = [
    aws_security_group.compute.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.ubuntu_root_volume_size
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
}

###############################################################################
# Windows member server
###############################################################################

resource "aws_instance" "windows_member" {
  ami           = data.aws_ami.windows.id
  instance_type = var.windows_instance_type
  subnet_id     = var.private_subnet_id

  vpc_security_group_ids = [
    aws_security_group.compute.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  associate_public_ip_address = false

  user_data = templatefile(
    "${path.module}/templates/windows-member-userdata.ps1.tftpl",
    {
      computer_name          = var.windows_computer_name
      domain_name            = var.domain_name
      domain_join_secret_arn = var.domain_join_secret_arn
      domain_ou_path         = var.domain_ou_path
      primary_dns_server     = var.domain_controller_private_ips[0]
      secondary_dns_server   = length(var.domain_controller_private_ips) > 1 ? var.domain_controller_private_ips[1] : var.domain_controller_private_ips[0]
      aws_region             = var.aws_region
    }
  )

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.windows_root_volume_size
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