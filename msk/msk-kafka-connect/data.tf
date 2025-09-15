data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

// -----------------
data "aws_subnet" "a" {
  filter {
    name   = "availability-zone"
    values = [ "${data.aws_vpc.default.region}a"]
  }
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "b" {
  filter {
    name   = "availability-zone"
    values = ["${data.aws_vpc.default.region}b"]
  }
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "c" {
  filter {
    name   = "availability-zone"
    values = ["${data.aws_vpc.default.region}c"]
  }
  vpc_id = data.aws_vpc.default.id
}


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


data "aws_kms_key" "rds" {
  key_id = "alias/aws/rds"
}

