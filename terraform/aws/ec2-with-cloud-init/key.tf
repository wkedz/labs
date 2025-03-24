# ssh-keygen -f ec2-keys
resource "aws_key_pair" "ec2-keys" {
  key_name   = var.ec2_key_name
  public_key = file("${var.ec2_key_name}.pub")
}