# Carrega o caller identity para tags auxiliares
data "aws_caller_identity" "current" {}


data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}