# Configures the remote state file to store in S3
terraform {
  backend "s3" {
    bucket         = "infrastructurebackup-616697378196-eu-central-2-an"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-central-2"
    encrypt        = true
    use_lockfile   = true
  }
}
