output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.amazonLinux.id
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.amazonLinux.name
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "vpc_id" {
  value = try(data.aws_vpcs.vpcs.ids[0], data.aws_vpc.default.id)
}

output "subnet_ids" {
  value = local.first_subnet_id
}

output "cidr_block" {
  value = local.cidr_block
}

output "instance_id" {
  value = aws_instance.this.id
}