resource "aws_ecs_service" "this" {
    cluster                            = data.aws_ecs_cluster.this.arn
    deployment_maximum_percent         = 100
    deployment_minimum_healthy_percent = 50
    desired_count                      = 2
    enable_ecs_managed_tags            = true
    enable_execute_command             = true
    health_check_grace_period_seconds  = 0
    launch_type                        = "FARGATE"
    name                               = "${var.ecs_service}-${var.environment}"
    scheduling_strategy                = "REPLICA"
    task_definition                    = aws_ecs_task_definition.this.arn
    deployment_circuit_breaker {
        enable   = false
        rollback = false
    }
    network_configuration {
        assign_public_ip = true
        #assign_public_ip = "${var.fargate_public_ip == "true" ? true : false}"
        security_groups  = [
            aws_security_group.this.id,
        ]
        subnets          = toset(data.aws_subnets.public.ids)
    }
}