resource "aws_glue_catalog_database" "vendas" {
  name        = var.glue_db_name
  description = "Database de vendas no Glue Data Catalog"
}

resource "aws_glue_catalog_table" "orders" {
  name          = var.glue_table_name
  database_name = var.glue_db_name
  catalog_id    = data.aws_caller_identity.current.account_id
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification                   = "csv"
    "skip.header.line.count"         = "1"
    "areColumnsQuoted"               = "false"
    "delimiter"                      = ","
  }

  storage_descriptor {
    location      = "s3://${local.bucket_name}/${var.glue_table_name}/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = var.glue_table_name
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"            = ","
        "skip.header.line.count" = "1"
      }
    }

    columns {
      name = "order_id"
      type = "int"
    }
    columns {
      name = "product_id"
      type = "int"
    }
    columns {
      name = "quantity"
      type = "int"
    }
    columns {
      name = "customer_id"
      type = "int"
    }
    columns {
      name = "order_date"
      type = "string"
    }
    columns {
      name = "delivery_date"
      type = "string"
    }
    columns {
      name = "campaign_id"
      type = "int"
    }
    columns {
      name = "media_source"
      type = "string"
    }
    columns {
      name = "payment_method"
      type = "int"
    }
  }

  depends_on = [aws_glue_catalog_database.vendas]
}
