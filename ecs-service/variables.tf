variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "sa-east-1"
}

variable "vpc_id" {
  description = "The AWS VPC"
  default     = "vpc-07728807b4a219059"
}

variable "environment" {
  description = "The environment to deploy"
  default     = "dev"
}

variable "ecs_cluster" {
  description = "The ECS Cluster to create the ECS Service"
  default     = "lab-wilton"
}

variable "ecs_service" {
  description = "The ECS Service"
  default     = "test-nginx"
}

variable "ecs_container_image" {
  description = "The ECS Image"
  default     = "nginx:stable"
}

variable "ecs_container_name" {
  description = "The ECS Container"
  default     = "nginx"
}

variable "fargate_public_ip" {
  default     = "false"
}

variable "load_balancer_public" {
  default     = "false"
}