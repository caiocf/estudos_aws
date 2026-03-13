# Usuário IAM já existente que será mantido como administrador do Lake Formation
# e também será o principal recomendado para executar apply/destroy.
data "aws_iam_user" "existing_admin" {
  user_name = var.existing_admin_user
}

# Permissão mínima para o novo usuário enxergar o database.
resource "aws_lakeformation_permissions" "new_user_database_describe" {
  principal   = aws_iam_user.aws_user.arn
  permissions = ["DESCRIBE"]

  database {
    name = aws_glue_catalog_database.main.name
  }

  depends_on = [aws_glue_catalog_database.main]
}

# Permissões Lake Formation - tabela Customers para o novo usuário.
resource "aws_lakeformation_permissions" "new_user_customers_table" {
  principal   = aws_iam_user.aws_user.arn
  permissions = ["ALL", "ALTER", "DELETE", "DESCRIBE", "DROP", "INSERT", "SELECT"]

  table {
    database_name = aws_glue_catalog_database.main.name
    name          = aws_glue_catalog_table.customers.name
  }

  depends_on = [aws_glue_catalog_table.customers]
}
