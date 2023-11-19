resource "aws_route53_zone" "internal" {
  name         = "vpc.internal."

  vpc {
    vpc_id = aws_vpc.main.id
  }
}
