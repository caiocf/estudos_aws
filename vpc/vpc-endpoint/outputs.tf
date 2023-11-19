
output "dns_lb" {
  value = aws_lb.lb_api.dns_name
}

output "nlb_endpoint_service_name" {
  value = aws_vpc_endpoint_service.nlb_endpoint_service.service_name
}

# Output para o DNS do VPC Endpoint a ser Chamado
output "vpc_endpoint_dns_entries" {
  value = aws_vpc_endpoint.vpc_endpoint_nlb_vpcB.dns_entry
}
