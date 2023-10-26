output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "subnets_private_id" {
  value = aws_subnet.private_subnets.*.id
}
output "subnets_public_id" {
  value = aws_subnet.public_subnets.*.id
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "subnet_private_a_id" {
  value = aws_subnet.private_subnets[0].id
}

output "subnet_private_b_id" {
  value = aws_subnet.private_subnets[1].id
}

output "subnet_private_c_id" {
  value = aws_subnet.private_subnets[2].id
}

output "subnet_public_a_id" {
  value = aws_subnet.public_subnets[0].id
}

output "subnet_public_b_id" {
  value = aws_subnet.public_subnets[1].id
}

output "subnet_public_c_id" {
  value = aws_subnet.public_subnets[2].id
}