variable "ec2_key_name" {
  description = "Name of keys used for ec2 instance "
  default     = "ec2-keys"
}

variable "aws_region" {
  description = "Used region."
  default     = "eu-west-1"
}

variable "amis" {
  description = "AMI type for given region."
  type        = map(string)
  default = {
    eu-west-1 = "ami-844e0bf7"
  }
}

variable "ec2_instance_type" {
  description = "EC2 instance type."
  default     = "t2.micro"
}

variable "device_name" {
  description = "Mount device name."
  default     = "/dev/xvdh"
}