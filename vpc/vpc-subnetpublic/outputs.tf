output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}


output "subnet_a_id" {
  value = aws_subnet.public_subnets[0].id
}

output "subnet_b_id" {
  value = aws_subnet.public_subnets[1].id
}

output "subnet_c_id" {
  value = aws_subnet.public_subnets[2].id
}

output "region" {
  value = var.region
}