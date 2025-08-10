resource "aws_security_group" "msk" {
  name        = "${var.project_name}-msk-sg"
  description = "MSK access"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Kafka TLS (SCRAM)"
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  ingress {
    description = "Kafka IAM"
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }


  ingress {
    description = "Kafka IAM aberto (remove de producao"
    from_port   = 9198
    to_port     = 9198
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", # Para posito de teste, usar em prod
                   aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}