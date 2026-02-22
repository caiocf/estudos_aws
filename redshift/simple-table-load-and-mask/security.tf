# Security Group para o Redshift
resource "aws_security_group" "redshift_sg" {
  name        = "Redshift-security-group"
  description = "Security Group for Redshift"
  vpc_id      = data.aws_vpc.default.id # Substitua pelo ID da sua VPC

  # Permitir tráfego de entrada do Redshift na porta padrão 5439
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  # Permitir todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Redshift Security Group"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
