data "aws_instance" "public" {
  instance_id = var.public_instance_id
}

data "aws_instance" "private" {
  instance_id = var.private_instance_id
}

locals {
  ssh_sg_name          = "${var.project_id}-ssh-sg"
  public_http_sg_name  = "${var.project_id}-public-http-sg"
  private_http_sg_name = "${var.project_id}-private-http-sg"

  common_tags = {
    Project = var.project_id
  }
}


resource "aws_security_group" "ssh_sg" {
  name        = local.ssh_sg_name
  description = "Allow SSH and ICMP from allowed IP ranges"
  vpc_id      = var.vpc_id

  tags = local.common_tags
}

resource "aws_security_group_rule" "ssh_ingress_ssh" {
  security_group_id = aws_security_group.ssh_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  description       = "Allow SSH from allowed IP ranges"
}

resource "aws_security_group_rule" "ssh_ingress_icmp" {
  security_group_id = aws_security_group.ssh_sg.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_range
  description       = "Allow ICMP from allowed IP ranges"
}


resource "aws_security_group" "public_http_sg" {
  name        = local.public_http_sg_name
  description = "Allow HTTP and ICMP from allowed IP ranges"
  vpc_id      = var.vpc_id

  tags = local.common_tags
}

resource "aws_security_group_rule" "public_http_ingress_http" {
  security_group_id = aws_security_group.public_http_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  description       = "Allow HTTP from allowed IP ranges"
}

resource "aws_security_group_rule" "public_http_ingress_icmp" {
  security_group_id = aws_security_group.public_http_sg.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_range
  description       = "Allow ICMP from allowed IP ranges"
}


resource "aws_security_group" "private_http_sg" {
  name        = local.private_http_sg_name
  description = "Allow HTTP and ICMP only from public HTTP security group"
  vpc_id      = var.vpc_id

  tags = local.common_tags
}

resource "aws_security_group_rule" "private_http_ingress_http" {
  security_group_id        = aws_security_group.private_http_sg.id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_http_sg.id
  description              = "Allow HTTP 8080 from public HTTP security group"
}

resource "aws_security_group_rule" "private_http_ingress_icmp" {
  security_group_id        = aws_security_group.private_http_sg.id
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.public_http_sg.id
  description              = "Allow ICMP from public HTTP security group"
}


resource "aws_network_interface_sg_attachment" "public_attach_ssh" {
  security_group_id    = aws_security_group.ssh_sg.id
  network_interface_id = data.aws_instance.public.network_interface_id
}

resource "aws_network_interface_sg_attachment" "public_attach_http" {
  security_group_id    = aws_security_group.public_http_sg.id
  network_interface_id = data.aws_instance.public.network_interface_id
}


resource "aws_network_interface_sg_attachment" "private_attach_ssh" {
  security_group_id    = aws_security_group.ssh_sg.id
  network_interface_id = data.aws_instance.private.network_interface_id
}

resource "aws_network_interface_sg_attachment" "private_attach_http" {
  security_group_id    = aws_security_group.private_http_sg.id
  network_interface_id = data.aws_instance.private.network_interface_id
}