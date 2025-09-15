
#############################
# Custom Plugin (Debezium)  #
#############################

resource "aws_s3_bucket" "plugin" {
  bucket        = "${var.project_name}-msk-plugins-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true

  region = var.region
}

resource "aws_mskconnect_custom_plugin" "debezium_pg" {
  name         = "${var.project_name}-debezium-postgres"
  content_type = "ZIP"

  location {
    s3 {
      bucket_arn     = aws_s3_bucket.plugin.arn
      file_key       = aws_s3_object.debezium_zip.key
      object_version = aws_s3_object.debezium_zip.version_id
    }
  }

  depends_on = [aws_s3_object.debezium_zip]
}


resource "aws_s3_object" "debezium_zip" {
  bucket = aws_s3_bucket.plugin.id
  key    = "plugins/debezium-connector-postgres-custom.zip"
  source = "${path.module}/plugins/debezium-connector-postgres-custom.zip"
}




########################################
# IAM: permitir MSK Connect ler o ZIP
########################################

# 1) IAM Role com trust policy do MSK Connect
resource "aws_iam_role" "msk_connect" {
  name = "${var.project_name}-msk-connect-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "kafkaconnect.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
  tags = { Project = var.project_name }
}

# 2) Política com permissões necessárias (S3, Secrets, KMS, EC2/ENI, Logs, Kafka IAM)
data "aws_iam_policy_document" "msk_connect_core" {
  # CloudWatch Logs (worker_log_delivery)
  statement {
    sid      = "CloudWatchLogs"
    actions  = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents","logs:DescribeLogStreams"]
    resources = ["*"] # escopar pro LogGroup é opcional
  }

  # ENIs & descrições de VPC (o MSK Connect cria ENIs nas subnets)
  statement {
    sid     = "VpcNetworking"
    actions = ["ec2:CreateNetworkInterface","ec2:DescribeNetworkInterfaces","ec2:DeleteNetworkInterface","ec2:DescribeSubnets","ec2:DescribeSecurityGroups","ec2:DescribeVpcs"]
    resources = ["*"]
  }

  # Ler o ZIP do plugin no S3
  statement {
    sid      = "ReadPluginFromS3"
    actions  = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.plugin.arn}/${aws_s3_object.debezium_zip.key}"]
  }

  # Ler o segredo do master (manage_master_user_password = true) + Decrypt
  statement {
    sid      = "AllowReadAuroraMasterSecret"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = ["*"]
  }
  statement {
    sid      = "AllowKmsDecryptForSecrets"
    actions  = ["kms:Decrypt"]
    resources = ["*"]
  }


  # Cluster
  statement {
    actions   = ["kafka-cluster:Connect","kafka-cluster:DescribeCluster","kafka-cluster:DescribeClusterDynamicConfiguration","kafka-cluster:AlterClusterDynamicConfiguration"]
    resources = [local.cluster_arn]
  }


  # Kafka IAM (autorização de acesso aos tópicos/grupos no cluster)
  statement {
    sid = "KafkaClusterPermissions"
    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:DescribeCluster",
      "kafka-cluster:DescribeClusterDynamicConfiguration",
      "kafka-cluster:AlterClusterDynamicConfiguration",
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:CreateTopic",
      "kafka-cluster:AlterTopic",
      "kafka-cluster:WriteData",
      "kafka-cluster:ReadData",
      "kafka-cluster:DescribeGroup",
      "kafka-cluster:AlterGroup"
    ]
    resources = [
      aws_msk_cluster.cluster.arn,
      "arn:aws:kafka:*:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.cluster.cluster_name}/*",
      "arn:aws:kafka:*:${data.aws_caller_identity.current.account_id}:cluster/${aws_msk_cluster.cluster.cluster_name}/*",
      "arn:aws:kafka:*:*:group/${data.aws_caller_identity.current.account_id}/*"
    ]
  }

  # Topics – TODOS (inclui __amazon_msk_connect_* e seus outbox.*)
  statement {
    actions = ["kafka-cluster:CreateTopic","kafka-cluster:DescribeTopic","kafka-cluster:AlterTopic","kafka-cluster:WriteData","kafka-cluster:ReadData"]
    resources = ["${local.topic_prefix_arn}/*"]
  }

  # Groups – TODOS
  statement {
    actions   = ["kafka-cluster:DescribeGroup","kafka-cluster:AlterGroup"]
    resources = ["${local.group_prefix_arn}/*"]
  }
}

resource "aws_iam_policy" "msk_connect_kafka_iam" {
  name   = "${var.project_name}-MSKConnectKafkaIAM"
  policy = data.aws_iam_policy_document.msk_connect_core.json
}

resource "aws_iam_role_policy_attachment" "attach_msk_connect_kafka_iam" {
  role       = aws_iam_role.msk_connect.name
  policy_arn = aws_iam_policy.msk_connect_kafka_iam.arn
}


#####################################
# Worker Configuration (Secrets Provider)
#####################################
resource "aws_mskconnect_worker_configuration" "debezium_worker_cfg" {
  name        = "${var.project_name}-worker-cfg"
  description = "Worker cfg com AWS Secrets Manager Config Provider"

  properties_file_content = <<-PROPS
    key.converter=org.apache.kafka.connect.storage.StringConverter
    value.converter=org.apache.kafka.connect.json.JsonConverter
    key.converter.schemas.enable=false
    value.converter.schemas.enable=false

    config.providers=secretsmanager,s3import
    config.providers.secretsmanager.class=com.amazonaws.kafka.config.providers.SecretsManagerConfigProvider
    config.providers.s3import.class=com.amazonaws.kafka.config.providers.S3ImportConfigProvider
    config.providers.secretsmanager.param.region=${var.region}


    # offset.storage.topic=offsets_my_debezium_source_connector
    # config.providers=secretsmanager,ssm,s3import
    # config.providers.secretsmanager.class    = com.amazonaws.kafka.config.providers.SecretsManagerConfigProvider
    # config.providers.ssm.class               = com.amazonaws.kafka.config.providers.SsmParamStoreConfigProvider
    # config.providers.s3import.class          = com.amazonaws.kafka.config.providers.S3ImportConfigProvider
    # config.providers.secretsmanager.param.region=${var.region}
  PROPS
}


########################################
# Conector Debezium (PostgreSQL -> MSK)
########################################
resource "aws_mskconnect_connector" "debezium_pg" {
  depends_on = [aws_rds_cluster.this, aws_msk_cluster.cluster,aws_secretsmanager_secret_version.database_endpoint]
  name                       = "${var.project_name}-debezium-pg"
  #kafkaconnect_version       = "2.7.1"
  kafkaconnect_version       = "3.7.x"
  service_execution_role_arn = aws_iam_role.msk_connect.arn

    capacity {
    autoscaling {
      mcu_count        = 1
      min_worker_count = 1
      max_worker_count = 2

      scale_in_policy {
        cpu_utilization_percentage = 20
      }

      scale_out_policy {
        cpu_utilization_percentage = 80
      }
    }
  }

plugin  {
  custom_plugin {
    arn      = aws_mskconnect_custom_plugin.debezium_pg.arn
    revision = aws_mskconnect_custom_plugin.debezium_pg.latest_revision
  }
}

# Worker config com Secrets Provider
worker_configuration {
  arn      = aws_mskconnect_worker_configuration.debezium_worker_cfg.arn
  revision = aws_mskconnect_worker_configuration.debezium_worker_cfg.latest_revision
}

connector_configuration = {
  "connector.class" = "io.debezium.connector.postgresql.PostgresConnector"
  "plugin.name"     = "pgoutput"
  "tasks.max"       = "1"


  "database.hostname" = aws_rds_cluster.this.endpoint
  "database.port"     = aws_rds_cluster.this.port
  #"database.user"     = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["username"]
  #"database.password" = jsondecode(aws_secretsmanager_secret_version.rds_master.secret_string)["password"]

  "database.user"     = "$${secretsmanager:${aws_secretsmanager_secret.rds_master.name}:username}"
  "database.password" = "$${secretsmanager:${aws_secretsmanager_secret.rds_master.name}:password}"
  "database.dbname"   = aws_rds_cluster.this.database_name
  "database.sslmode"  = "require"

  "slot.name"                   = "debezium_slot"
  "publication.name"            = "debezium_pub"
  "publication.autocreate.mode" = "filtered"
  "slot.drop.on.stop"           = "false"

  "topic.prefix"          = "pg"
  "schema.include.list"   = "public",
  "table.include.list"    = "public.outbox"

  "snapshot.mode"                 = "no_data"
  "tombstones.on.delete"          = "false"
  "provide.transaction.metadata"  =  "true"
  "heartbeat.interval.ms"         = "10000"
  "heartbeat.topics.prefix"       = "__debezium-heartbeat"

  "errors.tolerance"  = "all"
  "errors.log.enable" = "true"

  "errors.deadletterqueue.topic.name"             = "_dlq.debezium.aurora.pg"
  "errors.deadletterqueue.context.headers.enable" = "true"

  "table.include.list"                          = "public.outbox"
  "transforms"                                  = "outbox"
  "transforms.outbox.type"                      = "io.debezium.transforms.outbox.EventRouter"
  "transforms.outbox.table.expand.json.payload" = "true"
  "transforms.outbox.table.field.event.id"      = "id"
  "transforms.outbox.table.field.event.key"     = "aggregate_id"
  "transforms.outbox.table.field.event.payload" = "payload"
  "transforms.outbox.route.by.field"            = "aggregate_type"

  "transforms.outbox.table.fields.additional.placement" = "trace_id:header,tenant_id:header"

  "topic.creation.default.partitions"         = "3"
  "topic.creation.default.replication.factor" = "2"
  "tombstones.on.delete"                      = "false"
}


kafka_cluster {
  apache_kafka_cluster {
    bootstrap_servers = aws_msk_cluster.cluster.bootstrap_brokers_sasl_iam

    vpc {
      subnets         = [data.aws_subnet.a.id, data.aws_subnet.c.id]
      security_groups = [aws_security_group.msk.id]
    }
  }
}
kafka_cluster_client_authentication { authentication_type = "IAM" }
kafka_cluster_encryption_in_transit { encryption_type = "TLS" }

log_delivery {
  worker_log_delivery {
    cloudwatch_logs {
      enabled   = true
      log_group = aws_cloudwatch_log_group.test.name
    }
  }
}

tags = { Project = var.project_name, Stack = "msk-connect" }
}


