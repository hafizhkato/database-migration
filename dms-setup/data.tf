data "aws_vpc" "default" {
  default = true
}

# Get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "ec2_mysql_sg" {
  filter {
    name   = "group-name"
    values = ["mysql-onprem-sg"]
  }
}

data "aws_security_group" "rds_mysql_sg" {
  filter {
    name   = "group-name"
    values = ["rds-mysql-sg"]
  }
}

data "aws_db_instance" "mysql_rds" {
  db_instance_identifier = "portfolio-mysql-db"
}
