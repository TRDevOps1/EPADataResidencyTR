terraform {
  backend "s3" {
    bucket       = "terraform-state-aig"
    key          = "global/poc/storage.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
