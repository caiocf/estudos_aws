data "template_file" "openapi_petstore" {
  template = file("${path.module}/openapi_3/openapi-petstore.yaml")

  vars = {
    VPC_LINK_ID = aws_api_gateway_vpc_link.vpc_link.id
    URL_NLB_ENDPOINT = "http://${module.ec2_nlb.nlb_url_endpoint}/v3/pet"
  }
}
