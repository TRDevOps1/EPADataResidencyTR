###############################################################################
# Compute
#
# Creates:
# - 1 x Ubuntu 24.04 server
# - 1 x Windows Server 2022 member server
#
# Both servers use the same private subnet as the domain controller.
# The Windows server joins the existing AD domain.
###############################################################################

module "compute" {
  source = "./modules/compute"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.network.vpc_id

  # Same private subnet used by the domain controller
  private_subnet_id = module.network.private_subnet_ids[0]

  # EC2 instance sizes
  ubuntu_instance_type  = "t3.micro"
  windows_instance_type = "t3.medium"

  # Windows member server name
  windows_computer_name = "APP-MEMBER-01"

  # Existing Active Directory domain
  domain_name         = var.domain_name
  domain_netbios_name = var.domain_netbios_name

  # Use the domain controller as DNS
  domain_controller_private_ips = module.domain_controller.dns_server_ips

  # Domain credentials
  domain_administrator_password = var.domain_administrator_password

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    module.domain_controller
  ]
}

###############################################################################
# Allow Compute Servers to Access Domain Controller
###############################################################################

resource "aws_security_group_rule" "compute_to_domain_controller" {
  type = "ingress"

  security_group_id        = module.domain_controller.security_group_id
  source_security_group_id = module.compute.compute_security_group_id

  protocol  = "-1"
  from_port = 0
  to_port   = 0

  description = "Allow compute servers to communicate with the domain controller"
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