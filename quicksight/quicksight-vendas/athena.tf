resource "aws_athena_workgroup" "vendas" {
  name = var.athena_workgroup_name

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      expected_bucket_owner = data.aws_caller_identity.current.account_id
      output_location       = "s3://${local.athena_results_bucket}/query-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}
