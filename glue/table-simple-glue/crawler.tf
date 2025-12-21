/*
# O Crawler
resource "aws_glue_crawler" "dispositivos_crawler" {
  database_name = var.sor_db_name_source
  name          = "crawler-gestao-dispositivo"
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    # Apontamos para a raiz da tabela, ele vai descobrir as pastas anomesdia=...
    path = "${local.sor_s3bucket}/controles-cliente-gestao-dispositivo-efetuada/"
  }

  # Configuração de atualização: ele adiciona novas partições e ignora mudanças de schema se você preferir
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  # Opcional: Agendamento (ex: rodar todo dia às 02:00 AM)
  # schedule = "cron(0 2 * * ? *)"
}*/