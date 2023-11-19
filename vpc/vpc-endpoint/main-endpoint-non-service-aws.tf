# VPC B
data "aws_route53_zone" "internal_vpc_b" {
  name         = "vpc.internal."
  private_zone = true
  vpc_id       = module.criar_vpcB_regiao1.vpc_id
}

resource "aws_route53_record" "ptfe_service_vpc_b" {
  zone_id = data.aws_route53_zone.internal_vpc_b.zone_id
  name    = "ptfe.${data.aws_route53_zone.internal_vpc_b.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_vpc_endpoint.vpc_endpoint_nlb_vpcB.dns_entry[0]["dns_name"]]

  provider = aws.primary
}

# VPC A
data "aws_route53_zone" "internal_vpc_a" {
  name         = "vpc.internal."
  private_zone = true
  vpc_id       = module.criar_vpcA_regiao1.vpc_id
}


