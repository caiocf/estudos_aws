resource "random_id" "id" {
  byte_length = 8
}


/*data "aws_secretsmanager_secret_version" "db_password"{
  secret_id = var.arn_secret_pass
}*/



module "modulo-dms" {
  source = "../"
  application = var.application
  dms_vpc_security_group_ids =  [aws_security_group.dms_sg.id]
  dms_vpc_subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id, module.criar_vpcA_regiao1.subnet_b_id, module.criar_vpcA_regiao1.subnet_c_id]

  source_database_engine = "oracle"
  //source_database_extra_connection_attributes = "useLogminerReader=N;useBfile=Y;archivedLogDestId=1;additionalArchivedLogDestId=2;"
  source_database_extra_connection_attributes = "useLogminerReader=N;useBfile=Y;archivedLogDestId=1;additionalArchivedLogDestId=2"
  source_database_host = split(":", module.oracle.db_instance_endpoint)[0]
  source_database_name = module.oracle.db_instance_name
  source_database_password = module.oracle.db_instance_password
  source_database_port = split(":", module.oracle.db_instance_endpoint)[1]
  source_database_username = module.oracle.db_instance_username

  target_database_engine = "redshift"
  target_database_extra_connection_attributes = ""
  target_database_host = split(":", aws_redshift_cluster.default.endpoint)[0]
  target_database_name = aws_redshift_cluster.default.database_name
  target_database_password = aws_redshift_cluster.default.master_password
  target_database_port = split(":", aws_redshift_cluster.default.endpoint)[1]
  target_database_username = aws_redshift_cluster.default.master_username

  dms_task_migration_type = "full-load-and-cdc"
  replication_instance_class = "dms.t2.micro"
  replication_instance_storage = 20
  replication_instance_version = "3.5.2"
}



/*
module "modulo-dms" {
  source = "../"
  application = var.application
  dms_vpc_security_group_ids = var.dms_vpc_security_group_ids
  dms_vpc_subnet_ids = var.dms_vpc_subnet_ids

  source_database_engine = var.source_database_engine
  source_database_extra_connection_attributes = var.source_database_extra_connection_attributes
  source_database_host = var.source_database_host
  source_database_name = var.source_database_name
  source_database_password = var.source_database_password
  source_database_port = var.source_database_port
  source_database_username = var.source_database_username

  target_database_engine = var.target_database_engine
  target_database_extra_connection_attributes = var.target_database_extra_connection_attributes
  target_database_host = var.target_database_host
  target_database_name = var.target_database_name
  target_database_password = var.target_database_password
  target_database_port = var.target_database_port
  target_database_username = var.target_database_username

  dms_task_migration_type = var.dms_task_migration_type
  replication_instance_class = var.replication_instance_class
  replication_instance_storage = var.replication_instance_storage
  replication_instance_version = var.replication_instance_version
}
*/
