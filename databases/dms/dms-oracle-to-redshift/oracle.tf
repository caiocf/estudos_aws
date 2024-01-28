# Lookup the available instance classes for the custom engine for the region being operated in
data "aws_rds_orderable_db_instance" "custom-oracle" {
  engine                     = "oracle-ee" # CEV engine to be used
  engine_version             = "19.0.0.0.ru-2021-04.rur-2021-04.r1"      # CEV engine version to be used 19.0.0.0.ru-2023-10.rur-2023-10.r1
  license_model              = "bring-your-own-license"
  storage_type               = "gp3"
  preferred_instance_classes = ["db.t3.large"]
}


resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id]

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "default" {
  allocated_storage           = 50
  auto_minor_version_upgrade  = false                         # Custom for Oracle does not support minor version upgrades
  backup_retention_period     = 7
  db_subnet_group_name        = aws_db_subnet_group.default.name
  engine                      = data.aws_rds_orderable_db_instance.custom-oracle.engine
  engine_version              = data.aws_rds_orderable_db_instance.custom-oracle.engine_version
  identifier                  = "ee-instance-demo"
  instance_class              = data.aws_rds_orderable_db_instance.custom-oracle.instance_class
  kms_key_id                  = aws_kms_key.dms_kms_key.arn
  license_model               = data.aws_rds_orderable_db_instance.custom-oracle.license_model
  multi_az                    = false # Custom for Oracle does not support multi-az
  password                    = "avoid-plaintext-passwords"
  username                    = "test"
  storage_encrypted           = true
  skip_final_snapshot     = false
  final_snapshot_identifier = "snapshot-db"

  vpc_security_group_ids = [aws_security_group.dms_sg.id]

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
}

resource "aws_db_instance" "test-replica" {
  replicate_source_db         = aws_db_instance.default.identifier
  replica_mode                = "open-read-only"#"mounted"
  auto_minor_version_upgrade  = false
  #custom_iam_instance_profile = "AWSRDSCustomInstanceProfile" # Instance profile is required for Custom for Oracle. See: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-setup-orcl.html#custom-setup-orcl.iam-vpc
  backup_retention_period     = 7
  identifier                  = "ee-instance-replica"
  instance_class              = data.aws_rds_orderable_db_instance.custom-oracle.instance_class
  kms_key_id                  = aws_kms_key.dms_kms_key.arn
  multi_az                    = false # Custom for Oracle does not support multi-az
  skip_final_snapshot         = true
  storage_encrypted           = true
  vpc_security_group_ids = [aws_security_group.dms_sg.id]

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
}
