
# Criação do Network Load Balancer (NLB)
resource "aws_lb" "nlb" {
  provider = aws.primary

  name               = "nlb-api"
  internal           = true
  load_balancer_type = "network"
  subnets             = data.aws_subnets.default.ids // [element(sort(data.aws_subnets.default.ids), 0), element(sort(data.aws_subnets.default.ids), 1)]

  enable_deletion_protection = false

  security_groups = [aws_security_group.allow_ssh_vpcA_regiao1.id]

  tags = {
    Name = "ExampleNLB"
  }
}

# Criação do target group para o NLB
resource "aws_lb_target_group" "target_group" {
  name     = "target-group-api"
  port     = 8080
  protocol = "TCP"
  vpc_id   = data.aws_vpc.default.id # Substitua pelo ID do VPC desejado

  provider = aws.primary

  health_check {
    port                = 8080
    protocol            = "TCP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ExampleTargetGroup"
  }
}

# Associação do alvo da instância EC2 ao NLB
resource "aws_lb_target_group_attachment" "group_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.web_Vpc_A_Private.id
  port             = 8080
}

# Criação do listener do NLB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}