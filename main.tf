resource "aws_key_pair" "key" {
  key_name   = "${local.prefix}-key"
  public_key = file("./ssh/key.pub")
}

resource "aws_instance" "control_plane" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.control_plane.id]
  associate_public_ip_address = true
  private_ip                  = var.control_plane_private_ip
  user_data = templatefile(
    "scripts/bootstrap.sh",
    {
      hostname                 = var.control_plane_hostname,
      control_plane_private_ip = var.control_plane_private_ip,
      control_plane_hostname   = var.control_plane_hostname,
      worker_1_private_ip      = var.worker_1_private_ip,
      worker_1_hostname        = var.worker_1_hostname,
      worker_2_private_ip      = var.worker_2_private_ip,
      worker_2_hostname        = var.worker_2_hostname
    }
  )

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = {
    Name = "${local.prefix}-control-plane"
  }
}

resource "aws_instance" "worker_1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.worker.id]
  associate_public_ip_address = true
  private_ip                  = var.worker_1_private_ip
  user_data = templatefile(
    "scripts/bootstrap.sh",
    {
      hostname                 = var.worker_1_hostname,
      control_plane_private_ip = var.control_plane_private_ip,
      control_plane_hostname   = var.control_plane_hostname,
      worker_1_private_ip      = var.worker_1_private_ip,
      worker_1_hostname        = var.worker_1_hostname,
      worker_2_private_ip      = var.worker_2_private_ip,
      worker_2_hostname        = var.worker_2_hostname
    }
  )

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = {
    Name = "${local.prefix}-worker-1"
  }
}

resource "aws_instance" "worker_2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.worker.id]
  associate_public_ip_address = true
  private_ip                  = var.worker_2_private_ip
  user_data = templatefile(
    "scripts/bootstrap.sh",
    {
      hostname                 = var.worker_2_hostname,
      control_plane_private_ip = var.control_plane_private_ip,
      control_plane_hostname   = var.control_plane_hostname,
      worker_1_private_ip      = var.worker_1_private_ip,
      worker_1_hostname        = var.worker_1_hostname,
      worker_2_private_ip      = var.worker_2_private_ip,
      worker_2_hostname        = var.worker_2_hostname
    }
  )

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = {
    Name = "${local.prefix}-worker-2"
  }
}
