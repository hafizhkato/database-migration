output "security_group_id" {
  value = aws_security_group.mysql_sg.id
}

output "ec2_public_ip" {
  value = aws_instance.mysql_onprem.public_ip
}

output "subnet_a" {
    value = aws_subnet.subnet_a.id
  }

output "subnet_b" {
    value = aws_subnet.subnet_b.id
  }

output "subnet_c" {
    value = aws_subnet.subnet_c.id
  }
