resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${var.ecs_service}-${var.environment}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  family                    = "${var.ecs_service}-${var.environment}"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = 256
  memory                    = 512
  task_role_arn             = "${aws_iam_role.task-role.arn}"
  execution_role_arn        = "${aws_iam_role.task-exec-role.arn}"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  container_definitions     = <<EOF
[
  {
    "name": "${var.ecs_container_name}",
    "image": "${var.ecs_container_image}",
    "cpu": 64,
    "memory": 128,
    "memoryReservation": 128,
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.this.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOF
}
