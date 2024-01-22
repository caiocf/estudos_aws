resource "aws_security_group" "elastic_cache" {
  name = "app-4-elastic-cache"
  description = "Porta entrada e saida para cluste redis"

  ingress {
    from_port = 6379
    to_port = 6379
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