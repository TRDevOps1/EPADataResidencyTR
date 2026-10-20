###############################################################################
# Network
###############################################################################

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}

###############################################################################
# Domain controller
###############################################################################

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

###############################################################################
# Domain-join secret
#
# The Domain Administrator password is taken from the existing Terraform
# variable and stored as a JSON secret for the Windows member server.
###############################################################################

resource "aws_secretsmanager_secret" "domain_join" {
  name = "${var.project_name}-${var.environment}-domain-join"

  recovery_window_in_days = 0

  tags = {
    Name        = "${var.project_name}-${var.environment}-domain-join"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "domain_join" {
  secret_id = aws_secretsmanager_secret.domain_join.id

  secret_string = jsonencode({
    username = "${var.domain_netbios_name}\\Administrator"
    password = var.domain_administrator_password
  })
}

###############################################################################
# Compute
###############################################################################

module "compute" {
  source = "./modules/compute"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.network.vpc_id

  # Uses the same private subnet as the domain controller and FSx.
  private_subnet_id = module.network.private_subnet_ids[0]

  ubuntu_instance_type  = "t3.micro"
  windows_instance_type = "t3.medium"

  ubuntu_root_volume_size  = 20
  windows_root_volume_size = 50

  windows_computer_name = "APP-MEMBER-01"

  domain_name = var.domain_name

  # Reuses the DNS server IP output already used by FSx.
  domain_controller_private_ips = module.domain_controller.dns_server_ips

  # Windows retrieves the credentials directly from Secrets Manager.
  domain_join_secret_arn = aws_secretsmanager_secret.domain_join.arn

  # Leave empty if you do not have a dedicated member-server OU.
  domain_ou_path = ""

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    module.domain_controller,
    aws_secretsmanager_secret_version.domain_join
  ]
}

###############################################################################
# Permit the compute servers to communicate with the domain controller
#
# This is in the root module to avoid a circular dependency between the
# compute and domain-controller modules.
###############################################################################

resource "aws_security_group_rule" "compute_to_domain_controller" {
  type = "ingress"

  description = "Allow compute servers to access Active Directory services"

  security_group_id        = module.domain_controller.security_group_id
  source_security_group_id = module.compute.compute_security_group_id

  protocol  = "-1"
  from_port = 0
  to_port   = 0
}

###############################################################################
# FSx
###############################################################################

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

  organizational_unit_distinguished_name = (
    module.domain_controller.fsx_ou_distinguished_name
  )

  domain_controller_security_group_id = (
    module.domain_controller.security_group_id
  )

  depends_on = [
    module.domain_controller
  ]
}

###############################################################################
# Web application
###############################################################################

module "webapp" {
  source = "./modules/webapp"

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}