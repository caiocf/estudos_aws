# Data source para buscar configurações atuais do Lake Formation
data "aws_lakeformation_data_lake_settings" "current" {}

# Configuração dos administradores do Data Lake
# IMPORTANTE: Este recurso é criado primeiro e destruído por último
resource "aws_lakeformation_data_lake_settings" "main" {
  admins = distinct(concat(
    tolist(data.aws_lakeformation_data_lake_settings.current.admins),
    [
      data.aws_iam_user.existing_admin.arn,
      aws_iam_user.aws_user.arn
    ]
  ))

  lifecycle {
    create_before_destroy = true
  }
}

# Registro do bucket S3 como Data Lake Location
resource "aws_lakeformation_resource" "bucket" {
  arn                   = aws_s3_bucket.glue_lake.arn
  use_service_linked_role = true
  hybrid_access_enabled = false # Lake Formation only mode (recomendado)

  depends_on = [aws_lakeformation_data_lake_settings.main,aws_lakeformation_permissions.admin_database]
  
}
