# This file contains data sources for AWS resources that are used in the Terraform configuration.
# It retrieves information about the default VPC and subnets in the region.
# Lookup the default VPC
data "aws_vpc" "default" {
  default = true
}

# Lookup the default route table
data "aws_route_table" "default_rt" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}