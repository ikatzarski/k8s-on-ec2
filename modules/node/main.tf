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

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = {
    Name = var.name
  }
}
