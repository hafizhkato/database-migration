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
  # Outbound rule to allow connections to MySQL servers
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to the specific IP ranges or security groups
  }

  egress { # Allow all outbound traffic by default (can be made more restrictive)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

# Attach this KMS key to DMS or RDS during provisioning
resource "aws_kms_key" "dms_kms" {
  description             = "KMS key for DMS"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

resource "aws_dms_replication_instance" "dms_instance" {
  replication_instance_id     = "portfolio-dms-instance"
  replication_instance_class  = "dms.t3.micro" # free tier eligible
  allocated_storage           = 50
  publicly_accessible         = false
  auto_minor_version_upgrade  = true
  multi_az                    = false
  engine_version              = "3.5.3"
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_subnet_group.id
  vpc_security_group_ids      = [aws_security_group.dms_sg.id]
  tags = {
    Name = "PortfolioDMS"
  }
}

resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  replication_subnet_group_id          = "portfolio-dms-subnet-group"
  replication_subnet_group_description = "Subnet group for DMS replication instance"
  subnet_ids                           = [data.aws_subnets.default.ids[0],  # required by DMS to be in different AZs
                                         data.aws_subnets.default.ids[2] ]  
  tags = {
    Name = "DMS subnet group"
  }
}

resource "aws_dms_endpoint" "source_endpoint" {
  endpoint_id          = "source-ec2-mysql"
  endpoint_type        = "source"
  engine_name          = "mysql"
  username             = var.source_mysql_user
  password             = var.source_mysql_password
  server_name          = var.ec2_mysql_ip
  port                 = 3306
  database_name        = var.source_db_name
  ssl_mode             = "none" # or "require" if you're using SSL

  tags = {
    Name = "EC2 MySQL Source"
  }
}

resource "aws_dms_endpoint" "target_endpoint" {
  endpoint_id          = "target-rds-mysql"
  endpoint_type        = "target"
  engine_name          = "mysql"
  username             = var.rds_mysql_user
  password             = var.rds_mysql_password
  server_name          = data.aws_db_instance.mysql_rds.address
  port                 = 3306
  database_name        = var.target_db_name
  ssl_mode             = "none" # or "require" for encryption

  tags = {
    Name = "RDS MySQL Target"
  }
}

# resource "aws_dms_replication_task" "migration_task" {
#   replication_task_id          = "ec2-to-rds-mysql-migration"
#   replication_instance_arn     = aws_dms_replication_instance.dms_instance.replication_instance_arn
#   source_endpoint_arn          = aws_dms_endpoint.source_endpoint.endpoint_arn
#   target_endpoint_arn          = aws_dms_endpoint.target_endpoint.endpoint_arn
#   migration_type               = "full-load"
#   table_mappings               = file("json_file/table-mappings.json")
#   replication_task_settings    = file("json_file/task-settings.json")

#   tags = {
#     Name = "EC2 to RDS MySQL Migration Task"
#   }
# }



