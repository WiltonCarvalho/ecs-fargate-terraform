resource "aws_lb" "external" {
  name               = "External"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external.id]
  subnets            = toset(data.aws_subnets.public.ids)
  #subnets            = [for subnet in aws_subnet.public : subnet.id]
  enable_deletion_protection = false
  access_logs {
    bucket  = aws_s3_bucket.logs.bucket
    prefix  = "Logs"
    enabled = true
  }
  tags = {
    Name = "External"
  }
}

resource "aws_lb_listener" "external-http" {
  load_balancer_arn = aws_lb.external.arn
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
