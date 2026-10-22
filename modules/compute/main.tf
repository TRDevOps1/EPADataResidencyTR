# ==========================================================
# AMI LOOKUPS
# ==========================================================

# Latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Latest Windows Server 2025 AMI
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# ==========================================================
# SECURITY GROUPS
# ==========================================================

resource "aws_security_group" "ubuntu" {
  name        = "${var.project_name}-${var.environment}-ubuntu-sg"
  description = "Security group for Ubuntu server"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ubuntu-sg"
    Environment = var.environment
  }
}


resource "aws_security_group" "windows" {
  name        = "${var.project_name}-${var.environment}-windows-sg"
  description = "Security group for Windows server"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-windows-sg"
    Environment = var.environment
  }
}


# ==========================================================
# UBUNTU SERVER
# ==========================================================

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ubuntu_instance_type

  subnet_id = var.private_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-ubuntu"
    Environment = var.environment
  }
}


# ==========================================================
# WINDOWS SERVER
# ==========================================================

resource "aws_instance" "windows" {
  ami           = data.aws_ami.windows.id
  instance_type = var.windows_instance_type

  subnet_id = length(var.private_subnet_ids) > 1 ? var.private_subnet_ids[1] : var.private_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.windows.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-windows"
    Environment = var.environment
  }
}