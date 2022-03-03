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
