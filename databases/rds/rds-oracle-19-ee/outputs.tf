
# Output Oracle
output "oracle_endpoint" {
  value = module.db.db_instance_endpoint
}
output "oracle_username" {
  value = module.db.db_instance_username
  sensitive = true
}

output "oracle_db_name" {
  value = module.db.db_instance_name
}