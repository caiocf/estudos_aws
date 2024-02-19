# Security Group para o DMS
resource "aws_security_group" "dms_sg" {
  name        = "dms-security-group"
  description = "Security Group for DMS"
  vpc_id      = module.criar_vpcA_regiao1.vpc_id # Substitua pelo ID da sua VPC

  # Permitir tráfego de entrada do Oracle (substitua pelo IP do seu banco de dados Oracle)
  ingress {
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    //idr_blocks = [module.criar_vpcA_regiao1.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego de entrada do Redshift (substitua pelo IP do seu Redshift ou VPC peering)
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [module.criar_vpcA_regiao1.cidr_block]
  }

  # Permitir todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DMS Security Group"
  }
}