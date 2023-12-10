output "dns_alb" {
  value = "http://${aws_lb.alb.dns_name}:${aws_lb_listener.webserver_listener.port}/"
}