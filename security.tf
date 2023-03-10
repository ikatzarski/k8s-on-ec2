resource "aws_security_group" "control_plane" {
  name   = "${local.prefix}-control-plane"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-control-plane"
  }
}

resource "aws_security_group" "worker" {
  name   = "${local.prefix}-worker"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-worker"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = {
    control_plane_sg_id = aws_security_group.control_plane.id
    worker_sg_id        = aws_security_group.worker.id
  }

  security_group_id = each.value
  description       = "Allow SSH access from specific IP."
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.control_plane_ingress_cidr
}

resource "aws_vpc_security_group_ingress_rule" "api_server" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow K8s Api Server access from specific IP."
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.control_plane_ingress_cidr
}

resource "aws_vpc_security_group_ingress_rule" "from_workers" {
  security_group_id            = aws_security_group.control_plane.id
  description                  = "Allow access from the Worker Nodes."
  from_port                    = -1
  to_port                      = -1
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.worker.id
}

resource "aws_vpc_security_group_ingress_rule" "from_control_plane" {
  security_group_id            = aws_security_group.worker.id
  description                  = "Allow access from the Control Plane."
  from_port                    = -1
  to_port                      = -1
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.control_plane.id
}

resource "aws_vpc_security_group_ingress_rule" "from_worker_self" {
  security_group_id            = aws_security_group.worker.id
  description                  = "Allow access in-between Worker Nodes."
  from_port                    = -1
  to_port                      = -1
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.worker.id
}

resource "aws_vpc_security_group_egress_rule" "all_egress" {
  for_each = {
    control_plane_sg_id = aws_security_group.control_plane.id
    worker_sg_id        = aws_security_group.worker.id
  }

  security_group_id = each.value
  description       = "Allow all egress."
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
