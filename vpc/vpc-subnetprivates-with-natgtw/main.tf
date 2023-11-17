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

// private
resource "aws_subnet" "private_subnets" {
  count = 3
  vpc_id     = aws_vpc.main.id
  cidr_block =  cidrsubnet(var.cidr_vpc,8, count.index + 20)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name_vpc}-PRIVATE-${count.index+1}"
  }
}

resource "aws_route_table" "private-rtb" {
  count = 3
  depends_on = [aws_nat_gateway.nat,aws_vpc.main]

  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.name_vpc}-PRIVATE-RTB-${count.index+1}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count = 3

  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private-rtb[count.index].id
}

resource "aws_eip" "nat" {
  count = 3
}

resource "aws_nat_gateway" "nat" {
  depends_on = [aws_subnet.public_subnets,aws_eip.nat,aws_internet_gateway.igw]
  connectivity_type = "public"
  count = 3
  allocation_id  = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.name_vpc}-NAT-GW-SUBNET-${count.index+1} "
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



