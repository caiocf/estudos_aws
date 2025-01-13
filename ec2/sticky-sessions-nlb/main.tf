provider "aws" {
  region = "us-east-1"
}

# Criando uma VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Criando Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
}

# Criando o NLB
resource "aws_lb" "nlb" {
  name               = "example-nlb"
  load_balancer_type = "network"
  subnets            = aws_subnet.public[*].id
}

# Criando Target Group do NLB
resource "aws_lb_target_group" "nlb_target_group" {
  name        = "nlb-target-group"
  protocol    = "TCP"
  port        = 80
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  stickiness {
    type            = "source_ip"
    enabled         = true
    cookie_duration = 300 # Tempo em segundos (5 minutos)
  }
}

# Listener do NLB
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}
