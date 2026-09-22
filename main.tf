module "compute" {
  source = "./modules/compute"

  instance_count = var.instance_count
  instance_type  = var.instance_type
}

module "storage" {
  source = "./modules/storage"

  bucket_name = var.s3_bucket_name
}