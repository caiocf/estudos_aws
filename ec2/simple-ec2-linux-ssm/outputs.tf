output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.amazonLinux.id
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.amazonLinux.name
}

output "vpc_id" {
  value = local.vpc_id
}

output "subnet_ids" {
  value = local.subnet_id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}


output "instance_id" {
  value = aws_instance.this.id
}

output "primary_network_interface_id" {
  value = aws_instance.this.primary_network_interface_id
}

# Output para mostrar o nome da função IAM
output "roleExist" {
  value = local.roleExist
}

output "keyPairExist" {
  value = local.keyPairExist
}

output "instanceProfileExist" {
  value = local.ec2InstanceProfileExist
}
