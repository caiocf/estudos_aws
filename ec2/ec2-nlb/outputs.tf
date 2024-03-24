output "nlb_url_endpoint" {
  value = aws_lb.nlb.dns_name
}


output "nlb_arn" {
  value = aws_lb.nlb.arn
}

output "ec2_private_ip" {
  value = aws_instance.web_Vpc_A_Private.private_ip
}
