# EC2 AMI ID
variable "ami_id" {
  description = "AMI for EC2 instance"
  type        = string
  default     = "ami-0fa377108253bf620" 
}

# Instance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Key pair name
variable "key_name" {
  description = "SSH key name"
  type        = string
}