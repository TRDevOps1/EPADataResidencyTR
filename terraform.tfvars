aws_region     = "eu-central-2"
project_name = "windows-fsx-poc"
environment  = "poc"

instance_count = 2
instance_type  = "t3.micro"

s3_bucket_name = "tr-terraform-test-150"

vpc_cidr = "10.20.0.0/16"

domain_name         = "corp.example.com"
domain_netbios_name = "CORP"

fsx_service_account_name      = "svc-fsx"

allowed_management_cidr_blocks = [
  # Prefer access through SSM rather than opening RDP.
  # "192.0.2.10/32"
]