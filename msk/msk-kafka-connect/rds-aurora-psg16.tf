# Grupo de subnets do RDS
resource "aws_db_subnet_group" "this" {
  name       = "aurora-pg-slsv2-subnets"
  subnet_ids =  [data.aws_subnet.a.id, data.aws_subnet.c.id]
  description = "Subnets privadas para Aurora PostgreSQL Serverless v2"
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = "aurora-pg16-cluster-pg"
  family      = "aurora-postgresql16"
  description = "Cluster parameter group Aurora PG 16"

  # Exemplo: ajuste parâmetros
  # parameter {
  #   name  = "rds.force_ssl"
  #   value = "1"
  # }

  # Liga replicação lógica para MSK Connect
  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Replication.Logical.Configure.html
  # Aurora Serverless v2 suporta replicação lógica; Serverless v1 não suportava (https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.html)
  parameter {
    name = "rds.logical_replication"
    value = "1" # ON
    apply_method = "pending-reboot"
  }

  # Se for usar CDC/DMS/Debezium, ajuste os limites (também estáticos)
  # dimensione conforme sua necessidade e marque pending-reboot:
  # parameter {
  #   name         = "max_replication_slots"
  #   value        = "8"
  #   apply_method = "pending-reboot"
  # }
  # parameter {
  #   name         = "max_wal_senders"
  #   value        = "8"
  #   apply_method = "pending-reboot"
  # }
  # parameter {
  #   name         = "max_logical_replication_workers"
  #   value        = "4"
  #   apply_method = "pending-reboot"
  # }
  # parameter {
  #   name         = "max_worker_processes"
  #   value        = "8"
  #   apply_method = "pending-reboot"
  # }
}

resource "aws_db_parameter_group" "this" {
  name        = "aurora-pg16-instance-pg"
  family      = "aurora-postgresql16"
  description = "Instance parameter group Aurora PG 16"
}


resource "aws_rds_cluster" "this" {
  cluster_identifier = "aurora-pg16-slsv2-demo"  #
  engine             =  jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["engine"]
  port                = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["port"]              #

  engine_version     = "16.6"                    #
  database_name      = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["database_name"]         #
  master_username    = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["username"]              #
  master_password = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["password"]
  # manage_master_user_password = false  # (omita ou deixe false)

  skip_final_snapshot = true

  enable_http_endpoint = true
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.msk.id]
  storage_encrypted            = true
  kms_key_id                   = data.aws_kms_key.rds.arn
  copy_tags_to_snapshot        = true
  backup_retention_period      = 7
  preferred_backup_window      = "07:00-09:00"
  preferred_maintenance_window = "sun:03:00-sun:04:00"
  deletion_protection          = false



  # Serverless v2 (engine_mode omitido -> provisioned + scaling v2)
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 50
  }

  # IAM auth (habilite se suas telas estiverem com IAM = Habilitado)
  iam_database_authentication_enabled = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name


  tags = {
    Name = var.db_name_instance
    Env  = "dev"
  }
}

resource "random_password" "rds_master_alnum" {
  length      = 24
  special     = false      # <- sem caracteres especiais
  min_lower   = 4
  min_upper   = 4
  min_numeric = 4
}

# ------------------ INSTÂNCIAS ------------------
# Writer
resource "aws_rds_cluster_instance" "instance01" {
  identifier              = "${var.db_name_instance}-instance01"
  cluster_identifier      = aws_rds_cluster.this.id
  engine                  = aws_rds_cluster.this.engine

  engine_version          = aws_rds_cluster.this.engine_version
  instance_class          = "db.serverless"
  db_parameter_group_name = aws_db_parameter_group.this.name
  publicly_accessible     = false

  promotion_tier     = 0

  tags = {
    Name = "${var.db_name_instance}-instance01"
  }
}

resource "aws_secretsmanager_secret" "rds_master" {
  name = "rds-db-${var.db_name_instance}-credentials-user-${random_password.random_str_8.result}"
}

resource "aws_secretsmanager_secret_version" "rds_master" {
  secret_id = aws_secretsmanager_secret.rds_master.id
  secret_string = jsonencode({
    username      = "adminuser"
    password      = random_password.rds_master_alnum.result
    engine        = "aurora-postgresql"
    port          = 5432
    database_name = "appdb"
  })
}

resource "aws_secretsmanager_secret_version" "database_endpoint" {
  # Store endpoint after RDS cluster created
  secret_id = aws_secretsmanager_secret.rds_master.id
  secret_string = jsonencode({
    username = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["username"]
    password = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["password"]
    engine   = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["engine"]
    port     = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["port"]
    database_name = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["database_name"]

    endpoint = aws_rds_cluster.this.endpoint
    databse = aws_rds_cluster.this.database_name
  })
  depends_on = [aws_rds_cluster.this]
}


resource "aws_rds_cluster_instance" "instance02" {
  identifier              = "${var.db_name_instance}-instance02"
  cluster_identifier      = aws_rds_cluster.this.id
  engine                  = aws_rds_cluster.this.engine
  engine_version          = aws_rds_cluster.this.engine_version
  instance_class          = "db.serverless"
  db_parameter_group_name = aws_db_parameter_group.this.name
  publicly_accessible     = false
  promotion_tier          = 1

  tags = {
    Name = "${var.db_name_instance}-instance02"
  }
}