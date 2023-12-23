
resource "aws_dynamodb_table" "users" {
  name           = "user"
  billing_mode   = var.billing_mode_tf-table-users
  write_capacity = var.billing_mode_tf-table-users == "PROVISIONED" ? var.write_capacity_tf-table-user : null
  read_capacity = var.billing_mode_tf-table-users == "PROVISIONED" ? var.read_capacity_tf-table-user : null

  provider = aws.primary
  // Key
  hash_key       = "UserID"
  // Composite Key
  range_key      = "OrderID"

  attribute {
    name = "UserID"
    type = "N"
  }

  attribute {
    name = "OrderID"
    type = "N"
  }

  attribute {
    name = "Email"
    type = "S"
  }

  attribute {
    name = "LastLoginDate"
    type = "S"
  }

  // GSI
  global_secondary_index {
    name               = "EmailIndex"
    hash_key           = "Email"
    projection_type    = "ALL"
    write_capacity = var.write_capacity_gsi1-user
    read_capacity = var.read_capacity_gsi1-user
  }

  local_secondary_index {
    name               = "LoginDateIndex"
    range_key          = "LastLoginDate"
    projection_type    = "ALL"

  }

  ttl {
    attribute_name = "data_expiracao_registro"
    enabled = var.ttl_tf-table-user
  }

  stream_enabled = var.stream_enabled-user
  stream_view_type = var.stream_view_type-user

  point_in_time_recovery {
    enabled = true
  }
}


