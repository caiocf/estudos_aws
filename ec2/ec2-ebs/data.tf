data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_regiao1"{
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]

  provider = aws.primary
}
