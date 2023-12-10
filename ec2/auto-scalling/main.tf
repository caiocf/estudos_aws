resource "aws_lb_target_group" "tg_webserver" {
  name = "webserver-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = module.criar_vpcA_regiao1.vpc_id
  health_check {
    enabled = true
    healthy_threshold = 3
    interval = 30
    path = "/"
    port = "80"
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 3
  }
}

resource "aws_lb" "alb" {
  name = "alb-webserer"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.regra_http_ssh.id]
  subnets = [module.criar_vpcA_regiao1.subnet_public_a_id,module.criar_vpcA_regiao1.subnet_public_b_id,module.criar_vpcA_regiao1.subnet_public_c_id]
  preserve_host_header = true
}

resource "aws_lb_listener" "webserver_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 8080
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg_webserver.arn
  }
}


resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.webserver_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_webserver.arn
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}