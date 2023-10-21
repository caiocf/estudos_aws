output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.amazonLinux.id
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.amazonLinux.name
}

output "public_ip" {
  value = aws_instance.this.public_ip
}