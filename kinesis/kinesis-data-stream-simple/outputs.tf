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
