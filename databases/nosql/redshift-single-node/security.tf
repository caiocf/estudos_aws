resource "aws_security_group" "redshift_sg" {
  name        = "redshift_sg"
  description = "Security group for Redshift cluster"

  ingress {
    from_port = 5439
    to_port = 5439
    protocol = "tcp"
    cidr_blocks = [module.criar_vpcA_regiao1.cidr_block]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [module.criar_vpcA_regiao1.cidr_block]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = module.criar_vpcA_regiao1.vpc_id
}