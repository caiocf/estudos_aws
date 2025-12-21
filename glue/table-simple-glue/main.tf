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


resource "aws_glue_catalog_table" "tb1_gov" {
  name          = var.sor_table_name
  database_name = var.sor_db_name_source
  catalog_id    = local.control_account_id
  table_type    = "EXTERNAL_TABLE"

  /*parameters = {
    classification = "parquet"
  }*/

  parameters = {
    classification              = "parquet"
    "projection.enabled"        = "true"
    # Define que a partição 'anomesdia' é do tipo data
    "projection.anomesdia.type"   = "date"
    # Define o formato que você está usando nas pastas do S3
    "projection.anomesdia.format" = "yyyyMMdd"
    # Define o intervalo de datas que o Athena deve considerar
    "projection.anomesdia.range"  = "20230101,NOW"
    # Define o intervalo de tempo (1 dia)
    "projection.anomesdia.interval"      = "1"
    "projection.anomesdia.interval.unit" = "DAYS"
    # Indica ao Glue como montar o caminho no S3
    #"storage.location.template" = "${local.sor_s3bucket}/controles-cliente-gestao-dispositivo-efetuada/anomesdia=$${anomesdia}"
    "storage.location.template" = "s3://${local.sor_s3bucket}/${var.sor_table_name}/anomesdia=$${anomesdia}"
  }

  partition_keys {
    name = "anomesdia"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${local.sor_s3bucket}/${var.sor_table_name}/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "tb1"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name = "codigo_identificacao_cliente"
      type = "string"
    }

    columns {
      name    = "codigo_identificacao_token"
      type    = "string"
    }

    columns {
      name    = "descricao_situacao_disposition"
      type    = "string"
    }

    columns {
      name    = "numero_versao_sistema_operacional"
      type    = "string"
    }

    columns {
      name    = "nome_modelo_dispositivo_mobile"
      type    = "string"
    }

    columns {
      name    = "codigo_identificador_dispositivo_movel"
      type    = "string"
    }

    columns {
      name    = "numero_serie_dispositivo_seguranca"
      type    = "string"
    }
  }

  depends_on = [aws_glue_catalog_database.sor]
}