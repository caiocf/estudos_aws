output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.amazonLinux.id
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.amazonLinux.name
}

/*output "public_ip" {
  value = aws_instance.this.public_ip
}

output "instance_id" {
  value = aws_instance.this.id
}

output "primary_network_interface_id" {
  value = aws_instance.this.primary_network_interface_id
}

output "key_name" {
  value = aws_instance.this.key_name
}*/

output "instanceProfileExist" {
  value = local.ec2InstanceProfileExist
}



