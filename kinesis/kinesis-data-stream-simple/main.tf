provider "aws" {
  region = var.aws_region
}

resource "aws_kinesis_stream" "this" {
  name             = var.stream_name
  retention_period = var.retention_hours

  # Modo ON_DEMAND (sem shards fixos)
  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = var.tags
}
