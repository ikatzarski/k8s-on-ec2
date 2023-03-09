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
  private_ip                  = "10.0.1.10"

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
  private_ip                  = "10.0.1.11"

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = {
    Name = "${local.prefix}-worker-1"
  }
}
