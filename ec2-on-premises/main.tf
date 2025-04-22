# Create 3 public subnets in different AZs
resource "aws_subnet" "subnet_a" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = cidrsubnet(data.aws_vpc.default.cidr_block, 8, 1) # 1st subnet
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = cidrsubnet(data.aws_vpc.default.cidr_block, 8, 2) # 2nd subnet
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1b"
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = cidrsubnet(data.aws_vpc.default.cidr_block, 8, 3) # 3rd subnet
  availability_zone       = "ap-southeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1c"
  }
}

# Associate the subnet with the default route table
resource "aws_route_table_association" "default_subnet_assoc" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = data.aws_route_table.default_rt.id
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql-onprem-sg"
  description = "Allow SSH and MySQL access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open for demo; restrict in prod
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open for testing; adjust in prod
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_mysql_data_access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_read_policy" {
  name = "EC2S3ReadPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "s3:ListBucket",
        Resource = "arn:aws:s3:::aws-project-management-0976",
        Condition = {
          StringLike = {
            "s3:prefix" = "mysql/*"
          }
        }
      },
      {
        Effect = "Allow",
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::aws-project-management-0976/mysql/*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_role.name
}

# MySQL EC2 instance
resource "aws_instance" "mysql_onprem" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.default_subnet.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  user_data              = file("scripts/install_mysql.sh")

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  depends_on = [aws_route_table_association.default_subnet_assoc]

  tags = {
    Name = "MySQL-OnPrem-Sim"
  }
}
