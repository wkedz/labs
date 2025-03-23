module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  for_each = var.vpcs
  name     = each.key
  cidr     = each.value.cidr

  azs             = each.value.azs
  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets

  enable_nat_gateway = each.value.enable_nat_gateway
  enable_vpn_gateway = each.value.enable_vpn_gateway

  tags = each.value.tags
}