resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dms_vpc_access" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

# Security group for DMS
resource "aws_security_group" "dms_sg" {
  name        = "dms-security-group"
  description = "Allow DMS to access source and target databases"
  vpc_id      = data.aws_vpc.default.id
  tags = {
    Name = "dms-security-group"
  }
}

# Allow DMS to connect to EC2 MySQL
resource "aws_security_group_rule" "dms_to_ec2" {
  type                     = "ingress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"
  security_group_id       = data.aws_security_group.ec2_mysql_sg.id
  source_security_group_id = aws_security_group.dms_sg.id
}

# Allow DMS to connect to RDS MySQL
resource "aws_security_group_rule" "dms_to_rds" {
  type                     = "ingress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"
  security_group_id       = data.aws_security_group.rds_mysql_sg.id
  source_security_group_id = aws_security_group.dms_sg.id
}
