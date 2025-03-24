resource "aws_instance" "instance" {
  ami           = var.amis[var.aws_region]
  instance_type = var.ec2_instance_type

  subnet_id = aws_subnet.main-public-1.id

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  key_name = aws_key_pair.ec2-keys.key_name

  user_data = data.cloudinit_config.cloudinit.rendered
}

resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  device_name                    = var.device_name
  volume_id                      = aws_ebs_volume.ebs-volume-1.id
  instance_id                    = aws_instance.instance.id
  stop_instance_before_detaching = true
}

