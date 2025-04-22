# This file defines the variables used in the RDS module.

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_name" {
  default = "ecommerce"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "MyStrongPass123!"
}