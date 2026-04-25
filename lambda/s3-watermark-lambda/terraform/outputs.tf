output "bucket_name" {
  value       = aws_s3_bucket.images.bucket
  description = "S3 bucket name."
}

output "upload_prefix" {
  value       = "${trim(var.source_prefix, "/")}/"
  description = "Upload prefix."
}

output "watermarked_prefix" {
  value       = "${trim(var.destination_prefix, "/")}/"
  description = "Output prefix."
}

output "lambda_name" {
  value       = aws_lambda_function.watermark.function_name
  description = "Lambda function name."
}
