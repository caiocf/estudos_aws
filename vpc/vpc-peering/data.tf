
data "aws_ec2_instance_types" "available" {}

data "aws_ami" "amazonLinux_regiao1"{
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



data "aws_ami" "amazonLinux_regiao2" {
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

  provider = aws.secondary
}

