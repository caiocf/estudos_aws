

# Endpoint de Origem para Oracle
resource "aws_dms_endpoint" "oracle_source" {
  depends_on = [aws_db_instance.default]

  endpoint_id   = "oracle-source-endpoint"
  endpoint_type = "source"
  engine_name   = "oracle"

  ssl_mode                    = "none"
  username    = aws_db_instance.default.username
  password    = aws_db_instance.default.password
  server_name = split(":", aws_db_instance.default.endpoint)[0]
  port        = 1521 # Porta padrão do Oracle
  extra_connection_attributes = "useLogMinerReader=N;useBfile=Y;"
  database_name = aws_db_instance.default.db_name # "ORCL" # SID do Oracle

  tags = {
    Name = "Oracle Source Endpoint"
  }
}




# Endpoint de Destino para Redshift
resource "aws_dms_endpoint" "redshift_target" {
  endpoint_id   = "redshift-target-endpoint"
  endpoint_type = "target"
  engine_name   = "redshift"

  username =  aws_redshift_cluster.default.master_username
  password = aws_redshift_cluster.default.master_password
  server_name = split(":", aws_redshift_cluster.default.endpoint)[0]
  port     = 5439 # Porta padrão do Redshift

  database_name = aws_redshift_cluster.default.database_name
  service_access_role = aws_iam_role.dms-access-for-endpoint-redshift.arn

    redshift_settings {
      bucket_folder = "foo_dms"
      bucket_name = module.s3_logs.s3_bucket_id
      encryption_mode = "SSE_S3"
      service_access_role_arn = aws_iam_role.dms-access-for-endpoint-redshift.arn
    }

  #extra_connection_attributes = ""

  tags = {
    Name = "Redshift Target Endpoint"
  }
}



