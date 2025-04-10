data "aws_route53_zone" "my_zone" {
  name = "weles-soft.com"
}

resource "aws_eip" "my_eip" {
  instance = aws_instance.instance.id
}

resource "aws_route53_record" "instance_record" {
  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = "instance.weles-soft.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.my_eip.public_ip]
}
