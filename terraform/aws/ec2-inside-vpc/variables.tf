variable "instance_type" {
  description = "EC2 instance type (default t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "vpcs" {
  description = "VPC to create"
  type = map(object({
    cidr               = string,
    azs                = list(string),
    private_subnets    = list(string),
    public_subnets     = list(string),
    enable_nat_gateway = bool,
    enable_vpn_gateway = bool,
    tags               = optional(map(string))
  }))
}