/*
provider "aws" {
  region = "us-west-2" # Escolha a região apropriada
}

# DMS Replication Instance
resource "aws_dms_replication_instance" "dms_instance" {
  replication_instance_id          = "dms-instance-01"
  replication_instance_class       = "dms.t2.micro"
  allocated_storage                = 20

  vpc_security_group_ids           = [aws_security_group.dms_sg.id]  # Substitua pelo Security Group ID
  replication_subnet_group_id      = aws_dms_replication_subnet_group.dms_subnet_group.replication_subnet_group_id // "dms-subnet-group-01" # Substitua pelo Subnet Group ID

  tags = {
    Name = "DMS Instance"
  }
}

# DMS Replication Subnet Group
resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  replication_subnet_group_id          = "dms-subnet-group-01"
  replication_subnet_group_description = "DMS Subnet Group"
  subnet_ids                           = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"] # Substitua pelos Subnet IDs

  tags = {
    Name = "My DMS Subnet Group"
  }
}

# DMS Replication Task
resource "aws_dms_replication_task" "dms_task" {
  replication_task_id          = "dms-task-01"
  source_endpoint_arn          = aws_dms_endpoint.oracle_source.endpoint_arn
  target_endpoint_arn          = aws_dms_endpoint.redshift_target.endpoint_arn
  replication_instance_arn     = aws_dms_replication_instance.dms_instance.replication_instance_arn
  migration_type               = "full-load-and-cdc" # ou "full-load" ou "cdc" conforme sua necessidade

  table_mappings               = file("table-mappings.json") # Arquivo de mapeamento de tabelas

  replication_task_settings    = file("task-settings.json") # Arquivo de configurações da tarefa

  tags = {
    Name = "DMS Replication Task"
  }
}

*/
