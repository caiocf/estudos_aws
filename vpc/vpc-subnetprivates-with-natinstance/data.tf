
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

# Get test instance Image Id for Amazon Linux
data "aws_ami" "amzn-nat-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }
}