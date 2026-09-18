#Create AWS provider
provider "aws" {
  region = "eu-central-2"
}
#test
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
#adding comment to test2
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  count         = 2
  instance_type = "t3.micro"

  tags = {
    Name = "learn-terraform"
  }
}

resource "aws_s3_bucket" "s3" {
  bucket = "tr-terraform-test159"
}
