/*
resource "aws_lb" "example_nlb" {
  name               = "example-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["subnet-12345678", "subnet-87654321"]

  enable_deletion_protection = false
}


resource "aws_api_gateway_vpc_link" "example_vpc_link" {
  name        = "example-vpc-link"
  target_arns = [aws_lb.example_nlb.arn]
}

resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.petstore_api.id
  parent_id   = aws_api_gateway_rest_api.petstore_api.root_resource_id
  path_part   = "mypath"
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.petstore_api.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "NONE"
}
*/

/*
  forma generica
resource "aws_api_gateway_method" "example_method" {
  count        = length(var.http_methods)
  rest_api_id  = aws_api_gateway_rest_api.petstore_api.id
  resource_id  = aws_api_gateway_resource.example_resource.id
  http_method  = var.http_methods[count.index]
  authorization = "NONE"
}*//*


resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.petstore_api.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.example_nlb.dns_name}/targetpath"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.example_vpc_link.id
}




*/
