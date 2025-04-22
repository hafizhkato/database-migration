output "security_group_id" {
  value = aws_security_group.mysql_sg.id
}

output "ec2_public_ip" {
  value = aws_instance.mysql_onprem.public_ip
}