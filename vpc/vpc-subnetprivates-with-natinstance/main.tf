resource "random_string" "ssh_key_name" {
  length  = 8  # ou qualquer comprimento que você desejar
  special = false # definir como true se caracteres especiais forem necessários
  upper   = false # definir como true se letras maiúsculas forem necessárias
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_vpc
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
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

resource "aws_route" "to-instance" {
  depends_on = [aws_instance.server-nat-instance]
  count = 3
  route_table_id         = aws_route_table.private-rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"  # Rota padrão

  network_interface_id =  aws_instance.server-nat-instance.primary_network_interface_id
}

resource "aws_route_table" "private-rtb" {
  count = 3
  depends_on = [aws_vpc.main]

  vpc_id = aws_vpc.main.id
 /* route {
    cidr_block = "0.0.0.0/0"
    instance_id = module.nat_instance.instance_id
  }*/
  tags = {
    Name = "${var.name_vpc}-PRIVATE-RTB-${count.index+1}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count = 3

  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private-rtb[count.index].id
}


# Build the test instance


/*module "nat_instance" {

  source = "../../ec2/simple-ec2-linux-ssm"
  source_dest_check = true
  image_name_filter = "amzn-ami-vpc-nat*"
  map_public_ip_on_launch = true
  name_vpc = var.name_vpc

  region = var.region
}*/

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



