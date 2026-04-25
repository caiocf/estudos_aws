output "source_bucket_name" {
  value = aws_s3_bucket.source.bucket
}

output "destination_bucket_name" {
  value = aws_s3_bucket.destination.bucket
}

output "inventory_bucket_name" {
  value = aws_s3_bucket.inventory.bucket
}

output "reports_bucket_name" {
  value = aws_s3_bucket.reports.bucket
}

output "inventory_prefix" {
  value = local.inventory_prefix
}

output "next_step" {
  value = "After S3 Inventory generates the manifest.json, run terraform apply -var='enable_batch_job=true' -var='inventory_manifest_key=<manifest.json key>'."
}
