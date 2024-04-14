data "aws_canonical_user_id" "current" {}
data "aws_region" "current" {}

data "template_file" "openapi_site_lambda" {
  template = file("${path.module}/openapi_3/openapi-site-lambda-api.yaml")

  vars = {
    site-lambda-function_arn = aws_lambda_function.site-lambda-function.invoke_arn
    region  = var.region
  }
}


data "template_file" "s3_website_blog" {
  template = file("${path.module}/index.html")

  vars = {
    URL_API_GATEWAY = "${aws_api_gateway_deployment.site-lambda-deployment.invoke_url}${aws_api_gateway_stage.stage.stage_name}"
    region  = var.region
  }
}

locals {
  aws_region = data.aws_region.current.name
  # List taken from https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versionsx86-64.html
  lambdaInsightsLayers = {
    "us-east-1" : "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension:18",
    "us-east-2" : "arn:aws:lambda:us-east-2:580247275435:layer:LambdaInsightsExtension:18",
    "us-west-1" : "arn:aws:lambda:us-west-1:580247275435:layer:LambdaInsightsExtension:18",
    "us-west-2" : "arn:aws:lambda:us-west-2:580247275435:layer:LambdaInsightsExtension:18",
    "af-south-1" : "arn:aws:lambda:af-south-1:012438385374:layer:LambdaInsightsExtension:11",
    "ap-east-1" : "arn:aws:lambda:ap-east-1:519774774795:layer:LambdaInsightsExtension:11",
    "ap-south-1" : "arn:aws:lambda:ap-south-1:580247275435:layer:LambdaInsightsExtension:18",
    "ap-northeast-3" : "arn:aws:lambda:ap-northeast-3:194566237122:layer:LambdaInsightsExtension:1",
    "ap-northeast-2" : "arn:aws:lambda:ap-northeast-2:580247275435:layer:LambdaInsightsExtension:18",
    "ap-southeast-1" : "arn:aws:lambda:ap-southeast-1:580247275435:layer:LambdaInsightsExtension:18",
    "ap-southeast-2" : "arn:aws:lambda:ap-southeast-2:580247275435:layer:LambdaInsightsExtension:18",
    "ap-northeast-1" : "arn:aws:lambda:ap-northeast-1:580247275435:layer:LambdaInsightsExtension:25",
    "ca-central-1" : "arn:aws:lambda:ca-central-1:580247275435:layer:LambdaInsightsExtension:18",
    "eu-central-1" : "arn:aws:lambda:eu-central-1:580247275435:layer:LambdaInsightsExtension:18",
    "eu-west-1" : "arn:aws:lambda:eu-west-1:580247275435:layer:LambdaInsightsExtension:18",
    "eu-west-2" : "arn:aws:lambda:eu-west-2:580247275435:layer:LambdaInsightsExtension:18",
    "eu-south-1" : "arn:aws:lambda:eu-south-1:339249233099:layer:LambdaInsightsExtension:11",
    "eu-west-3" : "arn:aws:lambda:eu-west-3:580247275435:layer:LambdaInsightsExtension:18",
    "eu-north-1" : "arn:aws:lambda:eu-north-1:580247275435:layer:LambdaInsightsExtension:18",
    "me-south-1" : "arn:aws:lambda:me-south-1:285320876703:layer:LambdaInsightsExtension:11",
    "sa-east-1" : "arn:aws:lambda:sa-east-1:580247275435:layer:LambdaInsightsExtension:18"
  }
}