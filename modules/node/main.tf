data "aws_ami" "main" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240301"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "main" {
  ami                         = data.aws_ami.main.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  user_data = templatefile(
    "${path.module}/../../scripts/bootstrap.sh",
    {
      hostname                 = var.user_data_variables.hostname
      control_plane_private_ip = var.user_data_variables.control_plane_private_ip
      control_plane_hostname   = var.user_data_variables.control_plane_hostname
      worker_1_private_ip      = var.user_data_variables.worker_1_private_ip
      worker_1_hostname        = var.user_data_variables.worker_1_hostname
      worker_2_private_ip      = var.user_data_variables.worker_2_private_ip
      worker_2_hostname        = var.user_data_variables.worker_2_hostname
      token                    = var.user_data_variables.token
    }
  )

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = {
    Name = var.name
  }
}
