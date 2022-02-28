data "aws_availability_zones" "available" {
  state = "available"
}

# resource "aws_subnet" "az1" {
#   availability_zone = data.aws_availability_zones.available.names[0]
# }

# resource "aws_subnet" "az2" {
#   availability_zone = data.aws_availability_zones.available.names[1]
# }

# resource "aws_subnet" "az3" {
#   availability_zone = data.aws_availability_zones.available.names[2]
# }

output "availability_zones" {
  value = [data.aws_availability_zones.available.names]
}