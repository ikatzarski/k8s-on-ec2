module "network" {
  source = "./modules/network"

  prefix             = local.prefix
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnet_cidr = var.public_subnet_cidr
}

module "security" {
  source = "./modules/security"

  prefix              = local.prefix
  vpc_id              = module.network.vpc_id
  ingress_access_cidr = var.ingress_access_cidr
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "${local.prefix}-key"
  public_key = tls_private_key.main.public_key_openssh
}

resource "random_password" "token_start" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "token_end" {
  length  = 16
  special = false
  upper   = false
}

module "control_plane" {
  source = "./modules/node"

  name                   = "${local.prefix}-control-plane"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = module.network.public_subnet_id
  vpc_security_group_ids = [module.security.control_plane_security_group_id]
  private_ip             = var.control_plane_private_ip
  user_data_variables = {
    hostname                 = "control-plane"
    control_plane_private_ip = var.control_plane_private_ip
    control_plane_hostname   = "control-plane"
    worker_1_private_ip      = "${var.worker_private_ip_start}${var.worker_suffixes[0]}"
    worker_1_hostname        = "worker-${var.worker_suffixes[0]}"
    worker_2_private_ip      = "${var.worker_private_ip_start}${var.worker_suffixes[1]}"
    worker_2_hostname        = "worker-${var.worker_suffixes[1]}"
    token                    = "${random_password.token_start.result}.${random_password.token_end.result}"
  }
}

module "worker" {
  for_each = toset(var.worker_suffixes)
  source   = "./modules/node"

  name                   = "${local.prefix}-worker-${each.key}"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = module.network.public_subnet_id
  vpc_security_group_ids = [module.security.worker_security_group_id]
  private_ip             = "${var.worker_private_ip_start}${each.key}"
  user_data_variables = {
    hostname                 = "worker-${each.key}"
    control_plane_private_ip = var.control_plane_private_ip
    control_plane_hostname   = "control-plane"
    worker_1_private_ip      = "${var.worker_private_ip_start}${var.worker_suffixes[0]}"
    worker_1_hostname        = "worker-${var.worker_suffixes[0]}"
    worker_2_private_ip      = "${var.worker_private_ip_start}${var.worker_suffixes[1]}"
    worker_2_hostname        = "worker-${var.worker_suffixes[1]}"
    token                    = "${random_password.token_start.result}.${random_password.token_end.result}"
  }
}
