resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${var.environment}-${var.ecs_service}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  skip_destroy              = true
  family                    = "${var.environment}-${var.ecs_service}"
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
  container_definitions    = jsonencode([
    {
      name = "${var.ecs_container_name}"
      image = "${var.ecs_container_image}"
      essential = true
      cpu = 64
      memory = 128
      memoryReservation = 128
      portMappings = [
        {
          containerPort = var.ecs_container_port
          hostPort      = var.ecs_container_port
        }
      ]
      healthCheck = {
        retries     = 10
        command     = [ "CMD-SHELL", "curl -fsSL -H 'User-Agent: HealthCheck' http://localhost:${var.ecs_container_port}/ || exit 1" ]
        timeout     = 5
        interval    = 10
        startPeriod = 30
      }
      entryPoint = ["/bin/sh", "-c"]
      command = [
        <<-EOT
          cat <<'EOF'> /etc/nginx/conf.d/default.conf
          server_tokens off;
          server {
            listen 8080;
            server_name _;
            location / {
              default_type text/plain;
              expires -1;
              return 200 'Client address: $remote_addr $http_x_forwarded_for\nServer address: $server_addr:$server_port\nServer name: $hostname\nDate: $time_local\nURI: $request_uri\nRequest ID: $request_id\n';
            }
          }
          EOF
          exec nginx -g 'daemon off;'
        EOT
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "${aws_cloudwatch_log_group.this.name}"
          awslogs-region = "${var.aws_region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name = "alpine"
      image = "alpine"
      essential = true
      cpu = 64
      memory = 128
      memoryReservation = 128
      entryPoint = ["/bin/sh", "-c", "sleep infinity"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "${aws_cloudwatch_log_group.this.name}"
          awslogs-region = "${var.aws_region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
  # container_definitions = jsonencode(yamldecode(file("container_definitions.yaml")))
#   container_definitions     = <<EOF
# [
#   {
#     "name": "${var.ecs_container_name}",
#     "image": "${var.ecs_container_image}",
#     "cpu": 64,
#     "memory": 128,
#     "memoryReservation": 128,
#     "essential": true,
#     "logConfiguration": {
#       "logDriver": "awslogs",
#       "options": {
#         "awslogs-group": "${aws_cloudwatch_log_group.this.name}",
#         "awslogs-region": "${var.aws_region}",
#         "awslogs-stream-prefix": "ecs"
#       }
#     }
#   }
# ]
# EOF
}