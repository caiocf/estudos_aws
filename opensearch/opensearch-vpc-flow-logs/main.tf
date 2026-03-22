
resource "random_password" "admin_password" {
  length           = 20
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

resource "aws_opensearch_domain" "this" {
  domain_name     = var.domain_name
  engine_version  = var.engine_version
  ip_address_type = "dualstack"

  # Para laboratório com usuário interno (basic auth), deixamos o acesso HTTP
  # ser controlado pelo Fine-Grained Access Control.
  access_policies = data.aws_iam_policy_document.opensearch_access.json

  cluster_config {
    instance_type                 = var.instance_type
    instance_count                = var.data_node_count
    dedicated_master_enabled      = false
    warm_enabled                  = false
    multi_az_with_standby_enabled = false
    zone_awareness_enabled        = var.availability_zone_count > 1

    dynamic "zone_awareness_config" {
      for_each = var.availability_zone_count > 1 ? [1] : []

      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = 10
    iops        = 3000
    throughput  = 125
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = random_password.admin_password.result
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  auto_tune_options {
    desired_state = "ENABLED"
  }

  tags = {
    Name        = var.domain_name
    Environment = "academic-flow-logs"
    ManagedBy   = "terraform"
    Study       = "opensearch"
  }

  lifecycle {
    precondition {
      condition = (
        var.availability_zone_count == 1 && var.data_node_count >= 1
        ) || (
        var.availability_zone_count > 1 &&
        var.data_node_count >= var.availability_zone_count &&
        var.data_node_count % var.availability_zone_count == 0
      )
      error_message = "Para múltiplas AZs, data_node_count deve ser pelo menos igual ao número de AZs e múltiplo de availability_zone_count."
    }
  }
}
