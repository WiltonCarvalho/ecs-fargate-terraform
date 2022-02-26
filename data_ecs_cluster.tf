data "aws_ecs_cluster" "this" {
  cluster_name = "${var.ecs_cluster}"
}

output "aws_ecs_cluster" {
  value = [data.aws_ecs_cluster.this.arn]
}