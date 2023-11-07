/*
resource "aws_route53_resolver_rule" "example_rule" {
  name = "example-rule"
  domain_action {
    rule_action = "FORWARD"
    domain_name = "example.local"
  }
  rule_action {
    rule_action = "FORWARD"
    domain_name = "internal.local"
  }
}

resource "aws_route53_resolver_rule_association" "example_association" {
  rule_id         = aws_route53_resolver_rule.example_rule.id
  vpc_id          = "vpc-12345678" # Substitua pelo ID da sua VPC de origem
  rule_action     = "FORWARD"
  name            = "example-association"
  target_ip {
    ip = "10.0.0.2" # Substitua pelo endereço IP da VPC de destino
  }
}

resource "aws_route53_resolver_rule_association" "another_association" {
  rule_id         = aws_route53_resolver_rule.example_rule.id
  vpc_id          = "vpc-87654321" # Substitua pelo ID de outra VPC de origem
  rule_action     = "FORWARD"
  name            = "another-association"
  target_ip {
    ip = "10.0.1.2" # Substitua pelo endereço IP da outra VPC de destino
  }
}*/
