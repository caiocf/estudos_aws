data "aws_vpc" "default" {
  provider = aws.primary

  default = true
}

data "aws_subnets" "default" {
  provider = aws.primary

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_regiao1"{
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

  provider = aws.primary
}
