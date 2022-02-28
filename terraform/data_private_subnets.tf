data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*Private*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

output "vpc_id" {
  value = [var.vpc_id]
}

output "private_subnets" {
  value = [for s in data.aws_subnet.private : s.id]
}