
resource "aws_route53_record" "ptfe_service_blog" {
  zone_id = aws_route53_zone.internal_vpc_a.zone_id
  name    = "blog.${aws_route53_zone.internal_vpc_a.name}"
  type    = "A"
  ttl     = "5"

  set_identifier = "blog"

  records = [aws_instance.web_Vpc_A_Private.public_ip]
  weighted_routing_policy {
    weight = 25
  }


  health_check_id = aws_route53_health_check.A_Private.id

  provider = aws.primary
}

resource "aws_route53_record" "ptfe_service_live" {
  zone_id = aws_route53_zone.internal_vpc_a.zone_id
  name    = "blog.${aws_route53_zone.internal_vpc_a.name}"
  type    = "A"
  ttl     = "5"

  records = [aws_instance.web_Vpc_B_Private.public_ip]
  set_identifier = "live"

  weighted_routing_policy {
    weight = 75
  }

  health_check_id = aws_route53_health_check.B_Private.id

  provider = aws.primary
}


resource "aws_route53_record" "ptfe_service_www_1" {
  zone_id = aws_route53_zone.internal_vpc_a.zone_id
  name    = "www.${aws_route53_zone.internal_vpc_a.name}"
  type    = "A"
  ttl     = "5"

  records = [aws_instance.web_Vpc_A_Private.public_ip]
  set_identifier = "www_1"

  multivalue_answer_routing_policy = true

  health_check_id = aws_route53_health_check.A_Private.id

  provider = aws.primary
}


resource "aws_route53_record" "ptfe_service_www_2" {
  zone_id = aws_route53_zone.internal_vpc_a.zone_id
  name    = "www.${aws_route53_zone.internal_vpc_a.name}"
  type    = "A"
  ttl     = "5"

  records = [aws_instance.web_Vpc_B_Private.public_ip]
  set_identifier = "www_2"

  multivalue_answer_routing_policy = true

  health_check_id = aws_route53_health_check.B_Private.id

  provider = aws.primary
}



resource "aws_route53_health_check" "A_Private" {
  #fqdn              = "example.com"
  ip_address        = aws_instance.web_Vpc_A_Private.public_ip
  port              = 80
  type              = "HTTP"
  resource_path     = "/index.html"
  failure_threshold = "5"
  request_interval  = "10"

  tags = {
    Name = "tf-test-health-check"
  }
}


resource "aws_route53_health_check" "B_Private" {
  #fqdn              = "example.com"
  ip_address        = aws_instance.web_Vpc_B_Private.public_ip
  port              = 80
  type              = "HTTP"
  resource_path     = "/index.html"
  failure_threshold = "5"
  request_interval  = "10"

  tags = {
    Name = "tf-test-health-check"
  }
}



resource "aws_route53_zone" "internal_vpc_a" {
  name         = "mkcf"
  comment = "Private Zone"

  vpc {
    vpc_id = data.aws_vpc.default.id
  }
}