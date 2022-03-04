resource "aws_lb" "internal" {
  name               = "Internal"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal.id]
  subnets            = toset(data.aws_subnets.private.ids)
  #subnets            = [for subnet in aws_subnet.public : subnet.id]
  enable_deletion_protection = false
  access_logs {
    bucket  = aws_s3_bucket.logs.bucket
    prefix  = "Logs"
    enabled = true
  }
  tags = {
    Name = "Internal"
  }
}
resource "aws_lb_listener" "internal-http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden!"
      status_code  = "403"
    }
  }
}

data "dns_a_record_set" "internal_dns_name" {
  host = aws_lb.internal.dns_name
}

output "internal_dns_name" {
  value = aws_lb.internal.dns_name
}

output "internal_dns_addrs" {
  value = join(",", data.dns_a_record_set.internal_dns_name.addrs)
}