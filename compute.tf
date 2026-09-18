#resource "aws_instance" "web" {
#  ami           = var.ami_id
#  instance_type = var.instance_type
#
#  tags = {
#    Name = "web-server"
#  }
#}
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  count         = 2
  instance_type = "t3.micro"

  tags = {
    Name = "learn-terraform"
  }
}