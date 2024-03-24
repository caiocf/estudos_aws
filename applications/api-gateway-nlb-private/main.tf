
module "ec2_nlb" {
  source = "../../ec2/ec2-nlb"
  providers = {aws = aws.primary}
}

resource "aws_api_gateway_vpc_link" "vpc_link" {
  depends_on = [module.ec2_nlb]

  name        = "vpc-link-api"
  target_arns = [module.ec2_nlb.nlb_arn]

  provider = aws.primary
}

resource "aws_api_gateway_rest_api" "petstore_api" {
  name        = "PetstoreAPI"
  description = "This is a sample Pet Store Server based on the OpenAPI 3.0 specification"
  body        = data.template_file.openapi_petstore.rendered

  provider = aws.primary
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.petstore_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.petstore_api.id
  stage_name    = var.ambiente_stage

  xray_tracing_enabled = true
}

resource "aws_api_gateway_method_settings" "method_settings" {
  rest_api_id = aws_api_gateway_rest_api.petstore_api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
    data_trace_enabled = true
  }
}

resource "aws_api_gateway_deployment" "petstore_deployment" {
  rest_api_id = aws_api_gateway_rest_api.petstore_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.petstore_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  provider = aws.primary
}