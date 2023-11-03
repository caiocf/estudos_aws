
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
