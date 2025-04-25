output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_b" {
    value = data.aws_subnets.default.ids[0]
  }

output "subnet_a" {
    value = data.aws_subnets.default.ids[1]
  }

output "subnet_c" {
    value = data.aws_subnets.default.ids[2]
  }

output "ec2_mysql_security_group" {
  value = data.aws_security_group.ec2_mysql_sg.id
}

output "rds_security_group" {
  value = data.aws_security_group.rds_mysql_sg.id
}

output "rds_endpoint" {
  value = data.aws_db_instance.mysql_rds.endpoint
}