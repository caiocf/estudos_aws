output "url_api_gateway" {
  value = "${aws_api_gateway_deployment.site-lambda-deployment.invoke_url}${aws_api_gateway_stage.stage.stage_name}"
}

output "s3_bucket_id" {
  value = aws_s3_bucket_website_configuration.blog.website_endpoint
}