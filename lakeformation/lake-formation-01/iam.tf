# IAM User para consumo/consulta no Lake Formation
resource "aws_iam_user" "aws_user" {
  name = var.iam_user_name

  tags = {
    Name        = "Lake Formation User"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_user" "aws_user_2" {
  name = var.iam_user_2_name

  tags = {
    Name        = "Lake Formation Filtered User"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_user" "aws_user_3" {
  name = var.iam_user_3_name

  tags = {
    Name        = "Lake Formation Full Table Reader"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

data "aws_caller_identity" "current" {}

locals {
  current_caller_arn             = data.aws_caller_identity.current.arn
  current_caller_is_assumed_role = can(regex("^arn:[^:]+:sts::[0-9]+:assumed-role/.+$", local.current_caller_arn))
  current_caller_is_iam_role     = can(regex("^arn:[^:]+:iam::[0-9]+:role/.+$", local.current_caller_arn))
  current_caller_is_iam_user     = can(regex("^arn:[^:]+:iam::[0-9]+:user/.+$", local.current_caller_arn))
  current_cli_role_name = local.current_caller_is_assumed_role ? regex("^arn:[^:]+:sts::[0-9]+:assumed-role/([^/]+)/.+$", local.current_caller_arn)[0] : (
    local.current_caller_is_iam_role ? element(reverse(split("/", local.current_caller_arn)), 0) : null
  )
  current_cli_user_name = local.current_caller_is_iam_user ? element(reverse(split("/", local.current_caller_arn)), 0) : null
}

data "aws_iam_role" "current_cli_role" {
  count = local.current_cli_role_name != null ? 1 : 0
  name  = local.current_cli_role_name
}

data "aws_iam_user" "current_cli_user" {
  count     = local.current_cli_user_name != null ? 1 : 0
  user_name = local.current_cli_user_name
}

locals {
  current_lakeformation_admin_arn = local.current_cli_role_name != null ? data.aws_iam_role.current_cli_role[0].arn : (
    local.current_cli_user_name != null ? data.aws_iam_user.current_cli_user[0].arn : data.aws_caller_identity.current.arn
  )
  athena_primary_workgroup_arn = "arn:aws:athena:${var.aws_region}:${data.aws_caller_identity.current.account_id}:workgroup/primary"
  glue_catalog_arn             = "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog"
  glue_default_database_arn    = "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:database/default"
  glue_database_arn            = "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:database/${aws_glue_catalog_database.main.name}"
  glue_table_arn               = "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_glue_catalog_database.main.name}/${aws_glue_catalog_table.customers.name}"
  glue_table_wildcard_arn      = "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_glue_catalog_database.main.name}/*"
  athena_query_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LakeFormationDataAccess"
        Effect = "Allow"
        Action = [
          "lakeformation:GetDataAccess"
        ]
        Resource = "*"
      },
      {
        Sid    = "GlueCatalogReadAccess"
        Effect = "Allow"
        Action = [
          "glue:GetCatalog",
          "glue:GetCatalogs",
          "glue:GetCatalogImportStatus",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:GetTable",
          "glue:GetTables"
        ]
        Resource = [
          local.glue_catalog_arn,
          local.glue_default_database_arn,
          local.glue_database_arn,
          local.glue_table_arn,
          local.glue_table_wildcard_arn
        ]
      },
      {
        Sid    = "AthenaQueryAccess"
        Effect = "Allow"
        Action = [
          "athena:ListEngineVersions",
          "athena:GetDataCatalog",
          "athena:GetDatabase",
          "athena:BatchGetQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:GetQueryResultsStream",
          "athena:GetTableMetadata",
          "athena:ListDataCatalogs",
          "athena:ListDatabases",
          "athena:ListQueryExecutions",
          "athena:ListTableMetadata",
          "athena:ListWorkGroups"
        ]
        Resource = "*"
      },
      {
        Sid    = "AthenaWorkgroupAccess"
        Effect = "Allow"
        Action = [
          "athena:GetWorkGroup",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution"
        ]
        Resource = [
          aws_athena_workgroup.main.arn,
          local.athena_primary_workgroup_arn
        ]
      },
      {
        Sid    = "AthenaResultsBucketLocation"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.athena_results.arn
      },
      {
        Sid    = "AthenaResultsBucketList"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.athena_results.arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${var.workgroup_name}",
              "${var.workgroup_name}/*"
            ]
          }
        }
      },
      {
        Sid    = "AthenaResultsObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.athena_results.arn}/${var.workgroup_name}/*"
      }
    ]
  })
}

# Role dedicada para registrar a data location no Lake Formation.
# Evita a dependência da service-linked role, que pode falhar ao destruir
# a última S3 location registrada.
resource "aws_iam_role" "lakeformation_data_access" {
  name = "${var.database_name}-lf-data-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lakeformation.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "Lake Formation Data Access Role"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "lakeformation_data_access" {
  name = "${var.database_name}-lf-data-access-policy"
  role = aws_iam_role.lakeformation_data_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BucketMetadataAccess"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetBucketAcl",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = aws_s3_bucket.glue_lake.arn
      },
      {
        Sid    = "ObjectReadWriteAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "${aws_s3_bucket.glue_lake.arn}/*"
      }
    ]
  })
}

# Permissões mínimas de IAM para usar o Athena com Lake Formation.
# O acesso ao dado-fonte segue pelo Lake Formation; o usuário só precisa
# das ações do Athena, do GetDataAccess e do bucket de resultados.
resource "aws_iam_user_policy" "aws_user_athena_query_access" {
  name   = "${var.iam_user_name}-athena-query-access"
  user   = aws_iam_user.aws_user.name
  policy = local.athena_query_policy_json
}

resource "aws_iam_user_policy" "aws_user_2_athena_query_access" {
  name   = "${var.iam_user_2_name}-athena-query-access"
  user   = aws_iam_user.aws_user_2.name
  policy = local.athena_query_policy_json
}

resource "aws_iam_user_policy" "aws_user_3_athena_query_access" {
  name   = "${var.iam_user_3_name}-athena-query-access"
  user   = aws_iam_user.aws_user_3.name
  policy = local.athena_query_policy_json
}
