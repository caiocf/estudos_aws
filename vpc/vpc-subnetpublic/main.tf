provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_vpc
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags_all = {
    Name = var.name_vpc
  }
}

//-------------------- PUBLIC

resource "aws_subnet" "public_subnets" {
  depends_on = [aws_vpc.main]

  count = 3
  vpc_id     = aws_vpc.main.id
  cidr_block =  cidrsubnet(var.cidr_vpc,8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_vpc}-PUBLIC-${count.index+1}"
  }
}

resource "aws_route" "public_route" {
  depends_on = [aws_vpc.main,aws_internet_gateway.igw]
  route_table_id         =  aws_vpc.main.default_route_table_id  # Use [0] para a primeira tabela de roteamento
  destination_cidr_block = "0.0.0.0/0"  # Rota para a Internet
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_route_table_association" "rt_associate_public" {
  depends_on = [aws_vpc.main,aws_subnet.public_subnets]

  count = 3

  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_vpc.main.default_route_table_id
}

resource "aws_internet_gateway" "igw" {
  depends_on = [aws_vpc.main]

  vpc_id = aws_vpc.main.id
  tags = {
    Name= "${var.name_vpc}-IGW"
  }
}



