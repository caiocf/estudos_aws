# Data source para buscar usuário IAM existente
data "aws_iam_user" "existing_admin" {
  user_name = var.existing_admin_user
}

# Permissões Lake Formation - Database (para gerenciamento)
resource "aws_lakeformation_permissions" "admin_database" {
  principal                     = data.aws_iam_user.existing_admin.arn
  permissions                   = ["ALL", "ALTER", "CREATE_TABLE", "DESCRIBE", "DROP"]
  permissions_with_grant_option = ["ALL", "ALTER", "CREATE_TABLE", "DESCRIBE", "DROP"]

  database {
    name = aws_glue_catalog_database.main.name
  }
}

# Permissões Lake Formation - Tabela Customers (para consultas)
resource "aws_lakeformation_permissions" "admin_customers_table" {
  principal   = data.aws_iam_user.existing_admin.arn
  permissions = ["ALL", "ALTER", "DELETE", "DESCRIBE", "DROP", "INSERT", "SELECT"]

  # Descomente para adicionar Grantable permissions (Super)
  # permissions_with_grant_option = ["ALL", "ALTER", "DELETE", "DESCRIBE", "DROP", "INSERT", "SELECT"]

  table {
    database_name = aws_glue_catalog_database.main.name
    name          = aws_glue_catalog_table.customers.name
  }
}

# Permissões Lake Formation - Novo usuário IAM
resource "aws_lakeformation_permissions" "new_user_customers_table" {
  principal   = aws_iam_user.aws_user.arn
  permissions = ["ALL", "ALTER", "DELETE", "DESCRIBE", "DROP", "INSERT", "SELECT"]

  # Descomente para adicionar Grantable permissions (Super)
  # permissions_with_grant_option = ["ALL", "ALTER", "DELETE", "DESCRIBE", "DROP", "INSERT", "SELECT"]

  table {
    database_name = aws_glue_catalog_database.main.name
    name          = aws_glue_catalog_table.customers.name
  }
}


# Permissões Lake Formation - Data Location (necessário para criar database)
resource "aws_lakeformation_permissions" "admin_data_location" {
  principal   = data.aws_iam_user.existing_admin.arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = aws_s3_bucket.glue_lake.arn
  }

  depends_on = [aws_lakeformation_resource.bucket]
}
