
resource "aws_route53_record" "ptfe_service_vpc_a" {
  zone_id = aws_route53_zone.internal_vpc_a.zone_id
  name    = "ptfe.${aws_route53_zone.internal_vpc_a.name}"
  type    = "CNAME"
  ttl     = "300"

  records = [aws_instance.web_Vpc_A_Private.public_dns]

  provider = aws.primary
}

resource "aws_route53_zone" "internal_vpc_a" {
  name         = "mkcf"
  comment = "Private Zone"

  vpc {
    vpc_id = data.aws_vpc.default.id
  }
}