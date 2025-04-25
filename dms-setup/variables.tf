variable "source_mysql_user" {
    description = "Username for the source MySQL database"
    type        = string
    default     = "root"
}
variable "source_mysql_password" {
    description = "Password for the source MySQL database"
    type        = string
    default     = "MyStrongPass123!"
}
variable "source_db_name" {
    description = "Name of the source MySQL database"
    type        = string
    default     = "ecommerce"
}

variable "ec2_mysql_ip" {
    description = "IP address of the EC2 instance running MySQL"
    type        = string
    default     = "13.229.214.9" 
}

variable "rds_mysql_user" {
    description = "Username for the target RDS MySQL database"
    type        = string
    default     = "admin"
}
variable "rds_mysql_password" {
    description = "Password for the target RDS MySQL database"
    type        = string
    default    = "MyStrongPass123!"
}
variable "target_db_name" {
    description = "Name of the target RDS MySQL database"
    type        = string
    default     = "ecommerce"
}