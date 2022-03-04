data "aws_security_group" "external_lb" {
  filter {
    name   = "tag:Name"
    values = ["*external-lb*"]
  }
}

data "aws_security_group" "internal_lb" {
  filter {
    name   = "tag:Name"
    values = ["*internal-lb*"]
  }
}

resource "aws_security_group" "this" {
  vpc_id      = "${var.vpc_id}"
  name_prefix = "${var.environment}-${var.ecs_service}_"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  ingress {
    description = var.load_balancer_public == "true" ? "From External ELB SG" : "From Internal ELB SG"
    security_groups = var.load_balancer_public == "true" ? [data.aws_security_group.external_lb.id] : [data.aws_security_group.internal_lb.id]
    from_port   = var.ecs_container_port
    to_port     = var.ecs_container_port
    protocol    = "tcp"
  }
  tags = {
    Name = "${var.environment}-${var.ecs_service}"
  }
}