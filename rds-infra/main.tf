resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group"  # Name of the subnet group
  subnet_ids = [
    data.aws_subnets.default.ids[0],  # Uses the 1st subnet in the default VPC
    data.aws_subnets.default.ids[1]   # Uses the 2nd subnet (for multi-AZ redundancy)
  ]

  tags = {
    Name = "MySQL subnet group"  # Tag for identification
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"  # Name of the security group
  description = "Allow MySQL access"  # Description for documentation
  vpc_id      = data.aws_vpc.default.id  # Attaches to the default VPC

  # Ingress rule: Allow MySQL traffic (port 3306)
  ingress {
    from_port   = 3306  # MySQL default port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # WARNING: Too permissive! Restrict to specific IPs in production. Only allow your AWS DMS that you will setup later.
  }

  # Egress rule: Allow all outbound traffic
  egress {
    from_port   = 0      # All ports
    to_port     = 0
    protocol    = "-1"   # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysql_rds" {
  identifier        = "portfolio-mysql-db"  # Unique identifier for the DB
  engine            = "mysql"               # Database engine (MySQL)
  engine_version    = "8.0"                 # MySQL version 8.0
  instance_class    = var.db_instance_class # e.g., db.t3.micro (set via variable)
  allocated_storage = 20                    # Storage size in GB
  storage_type      = "gp2"                 # General Purpose SSD (consider "gp3" for newer projects)

  db_name           = var.db_name           # Initial database name (set via variable)
  username          = var.db_username       # Master username (set via variable)
  password          = var.db_password       # Master password (set via variable)
  #it is not recommend to store password here. You can use SSM to store any secret and call it from there.

  vpc_security_group_ids = [aws_security_group.rds_sg.id]  # Attaches the security group
  db_subnet_group_name   = aws_db_subnet_group.mysql_subnet_group.name  # Uses the subnet group

  backup_retention_period = 7              # Retain backups for 7 days
  backup_window           = "04:00-05:00"  # Daily backup window (UTC)

  monitoring_interval = 60  # Enables enhanced monitoring (60 seconds granularity)
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn  # IAM role for monitoring

  skip_final_snapshot = true  # WARNING: Set to `false` in production to avoid accidental deletion!

  publicly_accessible = true  # WARNING: Allows public connections. Set to `false` for private-only access.

  tags = {
    Name = "MySQL RDS Portfolio"  # Resource tag
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name = "rds-monitoring-role1"  # IAM role name

  # Trust policy: Allows RDS to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "monitoring.rds.amazonaws.com"  # Grants access to RDS monitoring service
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
  role       = aws_iam_role.rds_monitoring.name  # Attaches to the IAM role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"  # AWS-managed policy
}