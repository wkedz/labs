# ssh-keygen -f ec2-keys
resource "aws_key_pair" "ec2_keys" {
  key_name   = "ec2-keys"
  public_key = file("${path.module}/ec2-keys.pub")
}