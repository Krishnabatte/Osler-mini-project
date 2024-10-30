variable "aws_region" {
  default = "us-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "SSH Key Name"
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for the instance"
  type        = list(string)
}
