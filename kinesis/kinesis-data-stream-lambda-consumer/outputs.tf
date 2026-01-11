output "stream_name" {
  value       = aws_kinesis_stream.this.name
  description = "Nome do Kinesis Data Stream"
}

output "stream_arn" {
  value       = aws_kinesis_stream.this.arn
  description = "ARN do Kinesis Data Stream"
}

output "shard_count" {
  value       = aws_kinesis_stream.this.shard_count
  description = "Quantidade de shards provisionados"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Bucket S3 de destino (onde a Lambda salva os registros)"
}

output "lambda_name" {
  value       = aws_lambda_function.this.function_name
  description = "Nome da Lambda consumer"
}

output "event_source_mapping_uuid" {
  value       = aws_lambda_event_source_mapping.kinesis.uuid
  description = "UUID do mapeamento Kinesis -> Lambda"
}
