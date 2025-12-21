locals {
  control_account_id = coalesce(var.control_account, data.aws_caller_identity.current.account_id)
  sor_s3bucket = coalesce(
    var.sor_s3bucket,
    "corp-sor-sa-east-1-${data.aws_caller_identity.current.account_id}"
  )
}

resource "aws_glue_catalog_database" "sor" {
  name        = var.sor_db_name_source
  description = "Database do SOR no Glue Data Catalog"
}


# O Crawler
resource "aws_glue_crawler" "customers_crawler" {
  database_name = var.sor_db_name_source
  name          = "crawler-${var.sor_table_name}"
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    # Apontamos para a raiz da tabela, ele vai descobrir as pastas anomesdia=...
    path = "${local.sor_s3bucket}/${var.sor_table_name}/"
  }

  provisioner "local-exec" {
    command = "aws glue start-crawler --name ${self.name}"
  }

  # Configuração de atualização: ele adiciona novas partições e ignora mudanças de schema se você preferir
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  # Opcional: Agendamento (ex: rodar todo dia às 02:00 AM)
   schedule = "cron(0 2 * * ? *)"
}

