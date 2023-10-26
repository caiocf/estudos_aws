data "aws_ami" "amazonLinux"{
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

data "aws_vpcs" "vpcs" {
  tags = {
    Name = var.name_vpc
  }
}

data "aws_vpc" "default" {
  default = true  # Isso busca a VPC padrão (default) da conta
}

# Recupera informações sobre todas as sub-redes associadas à VPC identificada por local.vpc_id
data "aws_subnets" "all_subnets" {
  filter {
    name = "vpc-id"
    values = [local.vpc_id] # Usamos o ID da VPC encontrada ou da VPC padrão
  }
}

# Cria uma lista de informações detalhadas sobre cada sub-rede encontrada
data "aws_subnet" "subnets_list" {
  for_each = toset(data.aws_subnets.all_subnets.ids)
  id       = each.value
}

