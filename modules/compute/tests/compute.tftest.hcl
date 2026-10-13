# modules/compute/tests/compute.tftest.hcl

mock_provider "aws" {}


# --------------------------------------------------
# TEST 1
# Check that the correct EC2 instance type is used
# --------------------------------------------------

run "check_instance_type" {

  command = plan

  variables {
    ami_id        = "ami-1234567890"
    instance_type = "t3.micro"
    instance_name = "test-server"
  }

  assert {
    condition     = aws_instance.app.instance_type == "t3.micro"
    error_message = "EC2 instance type should be t3.micro."
  }
}


# --------------------------------------------------
# TEST 2
# Check that the EC2 instance receives the
# expected Name tag
# --------------------------------------------------

run "check_instance_name" {

  command = plan

  variables {
    ami_id        = "ami-1234567890"
    instance_type = "t3.micro"
    instance_name = "test-server"
  }

  assert {
    condition     = aws_instance.app.tags["Name"] == "test-server"
    error_message = "EC2 instance has an incorrect Name tag."
  }
}


# --------------------------------------------------
# TEST 3
# Check that the supplied AMI is being used
# --------------------------------------------------

run "check_ami" {

  command = plan

  variables {
    ami_id        = "ami-1234567890"
    instance_type = "t3.micro"
    instance_name = "test-server"
  }

  assert {
    condition     = aws_instance.app.ami == "ami-1234567890"
    error_message = "EC2 instance is using the wrong AMI."
  }
}