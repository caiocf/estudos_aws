# Busca as configurações atuais do Lake Formation para não sobrescrever admins existentes
data "aws_lakeformation_data_lake_settings" "current" {}

# Mantem os admins ja existentes do Lake Formation e adiciona o principal
# atual usado pelo provider/AWS CLI como admin do Data Lake.
resource "aws_lakeformation_data_lake_settings" "main" {
  admins = distinct(concat(
    tolist(data.aws_lakeformation_data_lake_settings.current.admins),
    [local.current_lakeformation_admin_arn]
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
