locals {
  private_subnets = flatten([
    for vpc_name, vpc in module.vpc : [
      for idx, subnet in vpc.private_subnets : {
        vpc_name  = vpc_name
        subnet_id = subnet
        index     = idx
      }
    ]
  ])
}

module "ec2_private_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  for_each = {
    for subnet in local.private_subnets :
    "${subnet.vpc_name}-${subnet.index}" => subnet
  }

  name                        = "${each.key}-private-instance"
  subnet_id                   = each.value.subnet_id
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = false

  vpc_security_group_ids = [aws_security_group.allow_ssh[each.value.vpc_name].id]
  key_name               = aws_key_pair.ec2_keys.key_name

  tags = {
    Name        = each.key
    Environment = "dev"
  }

  depends_on = [module.vpc]
}