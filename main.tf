module "compute" {
  source = "./modules/compute"

  instance_count = var.instance_count
  instance_type  = var.instance_type
}

module "storage" {
  source = "./modules/storage"

  bucket_name = var.s3_bucket_name
}

module "webapp" {
  source = "./modules/webapp"

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}

module "domain_controller" {
  source = "./modules/domain_controller"

  project_name = var.project_name
  environment  = var.environment

  vpc_id     = module.network.vpc_id
  vpc_cidr   = module.network.vpc_cidr
  subnet_id  = module.network.private_subnet_ids[0]
  private_ip = module.network.domain_controller_private_ips[0]

  domain_name         = var.domain_name
  domain_netbios_name = var.domain_netbios_name

  domain_administrator_password = var.domain_administrator_password

  fsx_service_account_name     = var.fsx_service_account_name
  fsx_service_account_password = var.fsx_service_account_password

  allowed_management_cidr_blocks = var.allowed_management_cidr_blocks
}

module "fsx" {
  source = "./modules/fsx"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.network.vpc_id

  # SINGLE_AZ_2 requires one subnet.
  subnet_ids = [
    module.network.private_subnet_ids[0]
  ]

  domain_name         = var.domain_name
  domain_netbios_name = var.domain_netbios_name

  dns_ips = module.domain_controller.dns_server_ips

  fsx_service_account_name     = var.fsx_service_account_name
  fsx_service_account_password = var.fsx_service_account_password

  organizational_unit_distinguished_name = module.domain_controller.fsx_ou_distinguished_name

  domain_controller_security_group_id = module.domain_controller.security_group_id

  depends_on = [
    module.domain_controller
  ]
}