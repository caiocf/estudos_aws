resource "aws_kms_key" "kms" {
  description = "${var.project_name}-key"
}

resource "aws_cloudwatch_log_group" "test" {
  name = "${var.project_name}-msk_logs"
}

resource "aws_msk_cluster" "cluster" {
  cluster_name = "${var.project_name}-msk"
  kafka_version = var.kafka_version
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type = var.broker_instance_type
    client_subnets = [data.aws_subnet.a.id, data.aws_subnet.c.id]
    security_groups = [aws_security_group.msk.id]

    storage_info {
      ebs_storage_info {
        volume_size = 210
      }
    }

    connectivity_info {
      public_access {
        type = var.public_access_type
      }
    }

  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.test.name
      }
      firehose {
        enabled         = false
      }
      s3 {
        enabled = false
      }

    }
  }

  client_authentication {
    sasl {
      scram = true
      iam = true
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  # monitoramento
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.rev3.arn
    revision = aws_msk_configuration.rev3.latest_revision
  }
}

# Secret SASL/SCRAM no Secrets Manager (precisa prefixo AmazonMSK_)
resource "aws_secretsmanager_secret" "msk_scram_secret" {
  name = "AmazonMSK_${var.msk_scram_username}_${random_password.random_str_8.result}"
  kms_key_id = aws_kms_key.kms.arn
}

resource "aws_secretsmanager_secret_version" "msk_scram_secret_ver" {
  secret_id     = aws_secretsmanager_secret.msk_scram_secret.id
  secret_string = jsonencode({ username = var.msk_scram_username, password = random_password.scram.result })
}

resource "random_password" "scram" {
  length  = 20
  special = false
}

resource "random_password" "random_str_8" {
  length  = 8
  special = false
  override_special = "_!#$%&*()-=+[]{}:;,.?\\"
}


# Associacao do secret com o cluster MSK
resource "aws_msk_scram_secret_association" "msk_scram" {
  cluster_arn = aws_msk_cluster.cluster.arn
  secret_arn_list = [aws_secretsmanager_secret.msk_scram_secret.arn]
}


# 1) Registrar o alvo escalável (VolumeSize por broker)
resource "aws_appautoscaling_target" "msk_storage" {
  service_namespace  = "kafka"
  scalable_dimension = "kafka:broker-storage:VolumeSize"
  resource_id        = aws_msk_cluster.cluster.arn

  # mínimo normalmente
  min_capacity = 1   # GiB
  max_capacity = 500   # GiB
}

# 2) Política de “target tracking” (Broker storage utilization)
resource "aws_appautoscaling_policy" "msk_storage_policy" {
  name               = "${aws_msk_cluster.cluster.cluster_name}-broker-storage-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = "kafka"
  scalable_dimension = aws_appautoscaling_target.msk_storage.scalable_dimension
  resource_id        = aws_appautoscaling_target.msk_storage.resource_id

  target_tracking_scaling_policy_configuration {
    # "alvo" de 80%
    target_value = 80

    predefined_metric_specification {
      # métrica de MSK:
      predefined_metric_type = "KafkaBrokerStorageUtilization"
    }

    # nao eh obrigatorio - cool-downs; MSK só escala 1x a cada 6h
    #scale_out_cooling_duration = 0
    disable_scale_in           = true  # MSK não faz scale-in de storage
  }

  depends_on = [aws_appautoscaling_target.msk_storage]
}


# msk-configuration.tf
resource "aws_msk_configuration" "rev3" {
  name           = "${var.project_name}-msk-config"
  description    = "Revisão via Terraform"
  kafka_versions = ["3.6.0"]

  server_properties = <<-PROPS
    auto.create.topics.enable = true
    default.replication.factor = 2
    log.retention.hours = 168
    min.insync.replicas = 1
    num.io.threads = 8
    num.network.threads = 5
    num.partitions = 2
    num.replica.fetchers = 2
    replica.lag.time.max.ms = 30000
    socket.receive.buffer.bytes = 102400
    socket.request.max.bytes = 104857600
    socket.send.buffer.bytes = 102400
    unclean.leader.election.enable = true
    zookeeper.session.timeout.ms = 18000
    allow.everyone.if.no.acl.found = false
  PROPS
}


resource "aws_msk_cluster_policy" "allow_all_for_testing" {
  cluster_arn = aws_msk_cluster.cluster.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # A) Permissões no RECURSO DE CLUSTER (conectar e descrever)
      {
        "Sid": "ClusterConnectAndDescribe",
        "Effect": "Allow",
        "Principal": "*",  # teste rápido; depois restrinja para ARNs específicos
        "Action": [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster"
        ],
        "Resource": [
          aws_msk_cluster.cluster.arn
        ]
      },

      # B) Operações de TÓPICO (prefixo demo-)
      {
        "Sid": "TopicCRUDDemoPrefix",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": [
          "kafka-cluster:CreateTopic",
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:AlterTopic",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData"
        ],
        "Resource": [
          "arn:aws:kafka:*:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.cluster.cluster_name}/${aws_msk_cluster.cluster.cluster_uuid}/demo-*"
        ]
      }
    ]
  })
}
