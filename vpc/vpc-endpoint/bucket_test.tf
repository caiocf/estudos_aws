resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "meu-bucket-16-11-2100"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "example_object" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "meuArquivo.txt"
  source = "meuArquivo.txt"
}