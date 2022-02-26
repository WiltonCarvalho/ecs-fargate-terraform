# resource "aws_ecs_task_definition" "example" {
# }
# # terraform import aws_ecs_task_definition.example arn:aws:ecs:sa-east-1:342878422924:task-definition/task-arm:8
# resource "aws_ecs_service" "example" {
# }
# # terraform import aws_ecs_service.example lab-wilton/test-arm
# # terraform show
# # terraform state rm 'aws_ecs_task_definition.example'
# # terraform state rm 'aws_ecs_service.example'