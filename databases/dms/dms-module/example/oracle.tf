# Lookup the available instance classes for the custom engine for the region being operated in
data "aws_rds_orderable_db_instance" "custom-oracle" {
  engine                     = "oracle-ee" # CEV engine to be used
  engine_version             = "19.0.0.0.ru-2021-04.rur-2021-04.r1"      # CEV engine version to be used 19.0.0.0.ru-2023-10.rur-2023-10.r1
  license_model              = "bring-your-own-license"
  storage_type               = "gp3"
  preferred_instance_classes = ["db.t3.large"]
}

resource "aws_db_subnet_group" "default" {
  name       = "main-${random_string.bucket_suffix.result}"
  subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id, module.criar_vpcA_regiao1.subnet_b_id, module.criar_vpcA_regiao1.subnet_c_id]
  tags = {
    Name = "My DB subnet group"
  }
}

# Criação de um Parameter Group para o banco de dados Oracle
resource "aws_db_parameter_group" "oracle_db_parameter_group" {
  name        = "oracle-custom-parameter-group-${random_string.bucket_suffix.result}"
  family      = "oracle-se2-19"
  description = "Parameter group for Oracle to enable supplemental logging"

  # Habilitar o log suplementar mínimo
  parameter {
    name  = "enable_goldengate_replication"
    value = "true"
  }

}

module "oracle" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier = "ee-instance-demo"

  engine               = "oracle-se2"
  engine_version       = "19.0.0.0.ru-2021-10.rur-2021-10.r1"
  family               = "oracle-se2-19"
  major_engine_version = "19"
  instance_class       = "db.t3.medium"
  license_model        = "license-included"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name                = "ORCL"
  username               = "db_user"
  password               = "avoid-plaintext-passwords"
  create_random_password = false
  port                   = 1521

  multi_az               = false

  db_subnet_group_name   = aws_db_subnet_group.default.name

  subnet_ids             = [module.criar_vpcA_regiao1.subnet_a_id, module.criar_vpcA_regiao1.subnet_b_id, module.criar_vpcA_regiao1.subnet_c_id]
  vpc_security_group_ids = [aws_security_group.dms_sg.id]
  create_db_parameter_group = true
  parameter_group_name   = aws_db_parameter_group.oracle_db_parameter_group.name

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  publicly_accessible     = true

  character_set_name = "AL32UTF8"
}






