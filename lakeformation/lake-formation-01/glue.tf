# Glue Catalog Database
resource "aws_glue_catalog_database" "main" {
  name         = var.database_name
  location_uri = "s3://${aws_s3_bucket.glue_lake.bucket}/"
  description  = "Data Lake database managed by Lake Formation"

  depends_on = [
    aws_lakeformation_data_lake_settings.main,
    aws_lakeformation_resource.bucket
  ]
}

# Glue Catalog Table - Customers
resource "aws_glue_catalog_table" "customers" {
  name          = "customers"
  database_name = aws_glue_catalog_database.main.name
  description   = "Customer data table"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.glue_lake.bucket}/customers/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
      }
    }

    columns {
      name    = "customer_id"
      type    = "int"
      comment = "Unique customer identifier"
    }

    columns {
      name    = "customer_name"
      type    = "string"
      comment = "Customer name"
    }

    columns {
      name    = "email"
      type    = "string"
      comment = "Customer email address"
    }

    columns {
      name    = "region"
      type    = "string"
      comment = "Customer region"
    }
  }

  depends_on = [
    aws_glue_catalog_database.main,
    aws_lakeformation_resource.bucket
  ]
}
