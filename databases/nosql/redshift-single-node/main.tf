
resource "aws_redshift_subnet_group" "subnet_redshift" {
  name       = "my-redshift-subnet-group"
  subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id]

  tags = {
    Name = "My Redshift Subnet Group"
  }
}

resource "aws_redshift_cluster" "redshift-cluster" {
  cluster_identifier  = var.cluster_identifier

  apply_immediately =  false
  node_type           = "dc2.large"
  number_of_nodes     = 1
  master_username     = "user_redshift"
  manage_master_password = true
  cluster_type        = "single-node"
  vpc_security_group_ids   = [aws_security_group.redshift_sg.id]
  database_name      = "vendasdb"
  cluster_parameter_group_name  = aws_redshift_parameter_group.this.name

  encrypted = true
  kms_key_id = aws_kms_key.redshift_key.arn
  cluster_subnet_group_name = aws_redshift_subnet_group.subnet_redshift.name
  publicly_accessible = false
  enhanced_vpc_routing = true

  skip_final_snapshot               = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  #snapshot_cluster_identifier       = var.snapshot_cluster_identifier
  #snapshot_identifier    = var.snapshot_identifier
  availability_zone_relocation_enabled = false

  automated_snapshot_retention_period = 1
  preferred_maintenance_window        = "Mon:00:30-Mon:01:00"

  dynamic "logging" {
    for_each = can(var.logging.enable) ? [var.logging] : []

    content {
      bucket_name          = try(logging.value.bucket_name, null)
      enable               = logging.value.enable
      log_destination_type = try(logging.value.log_destination_type, null)
      log_exports          = try(logging.value.log_exports, null)
      s3_key_prefix        = try(logging.value.s3_key_prefix, null)
    }
  }

  lifecycle {
    ignore_changes = [master_password]
  }
}

################################################################################
# Parameter Group
################################################################################

resource "aws_redshift_parameter_group" "this" {

  name        = coalesce(var.parameter_group_name, replace(var.cluster_identifier, ".", "-"))
  description = var.parameter_group_description
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, var.parameter_group_tags)
}


################################################################################
# Usage Limit
################################################################################

resource "aws_redshift_usage_limit" "this" {
  for_each = { for k, v in var.usage_limits : k => v}

  cluster_identifier = aws_redshift_cluster.redshift-cluster.id

  amount        = each.value.amount
  breach_action = try(each.value.breach_action, null)
  feature_type  = each.value.feature_type
  limit_type    = each.value.limit_type
  period        = try(each.value.period, null)

  tags = merge(var.tags, try(each.value.tags, {}))
}


################################################################################
# Endpoint Access
################################################################################


resource "aws_redshift_endpoint_access" "this" {
  count = var.create_endpoint_access ? 1 : 0

  cluster_identifier = aws_redshift_cluster.redshift-cluster.id

  endpoint_name          = "example-example"
  resource_owner         = var.endpoint_resource_owner
  subnet_group_name      = aws_redshift_subnet_group.subnet_redshift.name
  vpc_security_group_ids = [aws_security_group.redshift_sg.id]
}




