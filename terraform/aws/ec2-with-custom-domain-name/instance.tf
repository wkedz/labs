resource "aws_instance" "instance" {
  ami           = var.amis[var.aws_region]
  instance_type = var.ec2_instance_type

  subnet_id = aws_subnet.main-public-1.id

  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id]

  key_name = aws_key_pair.ec2-keys.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install apache2 -y
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
            EOF

  tags = {
    Name = "Apache2-Web"
  }  
}
