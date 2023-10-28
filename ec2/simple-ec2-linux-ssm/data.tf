
data "aws_ec2_instance_types" "available" {

}

data "aws_ami" "amazonLinux"{
  most_recent = true

  filter {
    name   = "name"
    values = [var.image_name_filter]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

data "aws_vpcs" "vpcs" {
  count = var.custom_vpc_id == "" ? 1 : 0
   filter {
     name   = "tag:Name"
     values = ["*PRODUCT*", "*Product*","*product*"]
   }
}

data "aws_vpc" "default" {
  default = true  # Isso busca a VPC padrão (default) da conta
}

# Recupera informações sobre todas as sub-redes associadas à VPC identificada por local.vpc_id
data "aws_subnets" "all_subnets_private" {
  filter {
    name = "vpc-id"
    values = [local.vpc_id] # Usamos o ID da VPC encontrada ou da VPC padrão
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = [var.filter_type_subnet_public]
  }
}

data "aws_subnets" "all_subnets_default" {
  filter {
    name = "vpc-id"
    values = [local.vpc_id] # Usamos o ID da VPC encontrada ou da VPC padrão
  }
}

# Cria uma lista de informações detalhadas sobre cada sub-rede encontrada
data "aws_subnet" "subnets_list" {
  for_each =   toset(data.aws_subnets.all_subnets_private.ids)
  id       = each.value
}

data "aws_subnet" "subnets_list_public" {
  for_each =   toset(data.aws_subnets.all_subnets_default.ids)
  id       = each.value
}

/*data "aws_key_pair" "keyNameSSH" {
  key_name = local.keyNameSSH
}*/
