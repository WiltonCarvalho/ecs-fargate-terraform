resource "aws_ecs_service" "this" {
    cluster                            = data.aws_ecs_cluster.this.arn
    deployment_maximum_percent         = 100
    deployment_minimum_healthy_percent = 50
    desired_count                      = 2
    enable_ecs_managed_tags            = true
    enable_execute_command             = true
    health_check_grace_period_seconds  = 0
    launch_type                        = "FARGATE"
    name                               = "${var.environment}-${var.ecs_service}"
    scheduling_strategy                = "REPLICA"
    task_definition                    = aws_ecs_task_definition.this.arn
    deployment_circuit_breaker {
        enable   = true
        rollback = true
    }
    network_configuration {
        assign_public_ip = "${var.fargate_public_ip == "true" ? true : false}"
        subnets          = "${var.fargate_public_ip == "true" ? toset(data.aws_subnets.public.ids) : toset(data.aws_subnets.private.ids)}"
        security_groups  = [
            aws_security_group.this.id,
        ]
    }
    load_balancer {
        container_name   = "${var.ecs_container_name}"
        container_port   = var.ecs_container_port
        target_group_arn = aws_lb_target_group.this.arn
    }
}

data "aws_lb" "external" {
    name = "External"
}

data "aws_lb" "internal" {
    name = "Internal"
}

data "aws_lb_listener" "external-http" {
    load_balancer_arn = data.aws_lb.external.arn
    port              = 80
}

data "aws_lb_listener" "internal-http" {
    load_balancer_arn = data.aws_lb.internal.arn
    port              = 80
}

resource "aws_lb_target_group" "this" {
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = "${var.vpc_id}"
    health_check {
        path = "/"
    }
    deregistration_delay = 30
}

resource "aws_lb_listener_rule" "http" {
    listener_arn = "${var.load_balancer_public == "true" ? data.aws_lb_listener.external-http.arn : data.aws_lb_listener.internal-http.arn}"
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.this.arn
    }
    condition {
        path_pattern {
            values = ["/*"]
        }
    }
    condition {
        host_header {
            values = ["nginx.wiltoncarvalho.com"]
        }
    }
}