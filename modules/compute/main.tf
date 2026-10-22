resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ubuntu_instance_type
  subnet_id     = var.private_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-ubuntu"
    Environment = var.environment
  }
}

resource "aws_instance" "windows" {
  ami           = data.aws_ami.windows.id
  instance_type = var.windows_instance_type

  # Put it in another existing private subnet if available
  subnet_id = length(var.private_subnet_ids) > 1
    ? var.private_subnet_ids[1]
    : var.private_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.windows.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-windows"
    Environment = var.environment
  }
}