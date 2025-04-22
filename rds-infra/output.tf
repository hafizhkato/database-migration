output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_id" {
    value = data.aws_subnets.default.ids[0]
  
}

output "rds_endpoint" {
  value = aws_db_instance.mysql_rds.endpoint
}