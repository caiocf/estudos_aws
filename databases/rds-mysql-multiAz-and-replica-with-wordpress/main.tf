locals {
  name   = "wordpressdb"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-rds"
  }

  engine                = "mysql"
  engine_version        = "5.7"
  family                = "mysql5.7" # DB parameter group
  major_engine_version  = "5.7"      # DB option group
  instance_class        = "db.t3.small"
  allocated_storage     = 5
  max_allocated_storage = 100
  port                  = 3306


  DB_NAME="wordpress"
  DB_USER="wordpress"
  DB_PASSWORD="wordpress"
}


module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.name

  engine            = local.engine
  engine_version    = local.engine_version
  instance_class    = local.instance_class
  allocated_storage = local.allocated_storage

  db_name  = local.DB_NAME
  username = local.DB_USER
  password = local.DB_PASSWORD
  manage_master_user_password = false
  port     = "3306"

  iam_database_authentication_enabled = false

  db_subnet_group_name = aws_db_subnet_group.meu_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.regra_http_ssh.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true
  publicly_accessible = false

  tags = {
    Owner       = "wordpress"
    Environment = "dev"
  }

  # DB subnet group
  create_db_option_group  = false
  subnet_ids             = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id]

  # Backups are required in order to create a replica
  backup_retention_period = 1
  skip_final_snapshot     = true
  multi_az = true

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = local.major_engine_version

  # Database Deletion Protection
  deletion_protection = false

  create_cloudwatch_log_group = true
  create_db_parameter_group = true

  parameters = [
    {
      name  = "character_set_client",
      value = "utf8"
    },
    {
      name  = "character_set_server",
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"
      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS",
          value = "CONNECT"
        }
      ]
    }
  ]
}

################################################################################
# Replica DB
################################################################################
module "replica" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.name}-replica"

  # Source database. For cross-region use db_instance_arn
  replicate_source_db = module.db.db_instance_identifier

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  port = local.port

  password = local.DB_PASSWORD
  # Not supported with replicas
  manage_master_user_password = false

  multi_az               = false
  vpc_security_group_ids = [aws_security_group.regra_http_ssh.id]

  maintenance_window              = "Tue:00:00-Tue:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = local.tags
}


resource "aws_db_subnet_group" "meu_db_subnet_group" {
  name       = "meu-subnet-group"
  subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id]

  tags = {
    Name = "Meu DB Subnet Group"
  }
}

