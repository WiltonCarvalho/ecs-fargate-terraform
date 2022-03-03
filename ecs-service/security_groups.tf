resource "aws_security_group" "this" {
  vpc_id      = "${var.vpc_id}"
  name_prefix = "${var.environment}-${var.ecs_service}_"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name = "${var.environment}-${var.ecs_service}"
  }
}