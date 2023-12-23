output "public_ip_ec2" {
  value = "http://${aws_instance.web_wordprees_instance.public_ip}"
}
output "db_address_database_master" {
  value = module.db.db_instance_address
}

output "db_address_database_replica" {
  value = module.replica.db_instance_address
}

output "db_az_master" {
  value = module.db.db_instance_availability_zone
}

output "db_az_replica" {
  value = module.replica.db_instance_availability_zone
}