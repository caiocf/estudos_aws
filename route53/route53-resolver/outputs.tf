output "test_instance_public_ip" {
  value = aws_instance.web_Vpc_A_Private.public_ip
}
