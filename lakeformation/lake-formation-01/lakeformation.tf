# Busca as configurações atuais do Lake Formation para não sobrescrever admins existentes
data "aws_lakeformation_data_lake_settings" "current" {}

# Mantém o administrador já existente.
# O principal usado para executar o Terraform não deve depender de
# aws_lakeformation_permissions do mesmo state para conseguir destruir o database.
resource "aws_lakeformation_data_lake_settings" "main" {
  admins = distinct(concat(
    tolist(data.aws_lakeformation_data_lake_settings.current.admins),
    [data.aws_iam_user.existing_admin.arn]
  ))
}

# Registra o bucket S3 no Lake Formation usando uma role dedicada.
# Isso evita o erro no destroy relacionado à service-linked role da AWS.
resource "aws_lakeformation_resource" "bucket" {
  arn                   = aws_s3_bucket.glue_lake.arn
  role_arn              = aws_iam_role.lakeformation_data_access.arn
  hybrid_access_enabled = false

  depends_on = [
    aws_lakeformation_data_lake_settings.main,
    aws_iam_role_policy.lakeformation_data_access
  ]
}
