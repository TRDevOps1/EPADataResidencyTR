terraform {
  backend "s3" {
    bucket       = "terraform-state-aig"
    key          = "global/s3/terraform-general.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
