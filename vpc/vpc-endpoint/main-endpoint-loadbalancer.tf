# VPC Provedora
data "aws_caller_identity" "current" {}

resource "aws_vpc_endpoint_service" "nlb_endpoint_service" {
  acceptance_required        = false
  # coloca listagem de conta que podera acessar
  allowed_principals         = [data.aws_caller_identity.current.arn,
                                  "arn:aws:iam::978473717587:root",
                                  "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  network_load_balancer_arns = [aws_lb.lb_api.arn]

  provider = aws.primary
}

# VPC Consumidora pode sem outa conta mas tem de ser mesma Regiao, mas pode ser contas diferentes
resource "aws_vpc_endpoint" "vpc_endpoint_nlb_vpcB" {
  vpc_endpoint_type = "Interface"
  service_name      = aws_vpc_endpoint_service.nlb_endpoint_service.service_name
  #subnet_ids        = [module.criar_vpcB_regiao1.subnet_private_a_id,module.criar_vpcB_regiao1.subnet_private_b_id,module.criar_vpcB_regiao1.subnet_private_c_id ]
  subnet_ids        = [module.criar_vpcB_regiao1.subnet_private_a_id,module.criar_vpcB_regiao1.subnet_private_c_id ]
  vpc_id            = module.criar_vpcB_regiao1.vpc_id

  security_group_ids = [aws_security_group.allow_ssh_vpcB_regiao1.id]

  provider = aws.primary
}
