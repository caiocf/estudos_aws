# Permissão de leitura em nível de coluna para o aws-user.
# O nome físico da coluna "regiao" no schema é "region".
resource "aws_lakeformation_permissions" "new_user_customers_columns" {
  principal   = aws_iam_user.aws_user.arn
  permissions = ["SELECT"]

  table_with_columns {
    database_name = aws_glue_catalog_database.main.name
    name          = aws_glue_catalog_table.customers.name
    column_names  = ["customer_name", "region"]
  }

  depends_on = [aws_glue_catalog_table.customers]
}

resource "aws_lakeformation_data_cells_filter" "aws_user_2_customers_na" {
  table_data {
    database_name    = aws_glue_catalog_database.main.name
    name             = "${var.iam_user_2_name}-customers-na-filter"
    table_catalog_id = data.aws_caller_identity.current.account_id
    table_name       = aws_glue_catalog_table.customers.name
    column_names     = ["email", "region"]

    row_filter {
      filter_expression = "region = 'NA'"
    }
  }

  timeouts {
    create = "2m"
  }

  depends_on = [aws_glue_catalog_table.customers]
}

resource "aws_lakeformation_permissions" "new_user_2_customers_na_filter" {
  principal   = aws_iam_user.aws_user_2.arn
  permissions = ["SELECT"]

  data_cells_filter {
    database_name    = aws_lakeformation_data_cells_filter.aws_user_2_customers_na.table_data[0].database_name
    name             = aws_lakeformation_data_cells_filter.aws_user_2_customers_na.table_data[0].name
    table_catalog_id = aws_lakeformation_data_cells_filter.aws_user_2_customers_na.table_data[0].table_catalog_id
    table_name       = aws_lakeformation_data_cells_filter.aws_user_2_customers_na.table_data[0].table_name
  }

  depends_on = [aws_lakeformation_data_cells_filter.aws_user_2_customers_na]
}

resource "aws_lakeformation_permissions" "new_user_3_all_tables_select" {
  principal   = aws_iam_user.aws_user_3.arn
  permissions = ["SELECT"]

  table {
    database_name = aws_glue_catalog_database.main.name
    wildcard      = true
  }
}
