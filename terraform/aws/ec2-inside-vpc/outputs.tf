output "ec2_public_instances_ips" {
  description = "IP addresses of exposed EC2 instances."
  value = {
    for k, m in module.ec2_public_instances :
    k => m.public_ip
  }
}