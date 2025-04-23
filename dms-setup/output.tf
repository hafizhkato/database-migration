output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_id" {
    value = data.aws_subnets.default.ids[0]
  
}

output "ec2_mysql_id" {
  value = data.aws_security_group.ec2_mysql_sg.id
}

output "rds_security_group" {
  value = data.aws_security_group.rds_mysql_sg.id
}

output "rds_endpoint" {
  value = data.aws_db_instance.mysql_rds.endpoint
}