# Opcional: criar um database próprio (recomendado)


resource "aws_glue_job" "job" {
  name     = var.glue_job_name
  role_arn = aws_iam_role.glue_role.arn

  glue_version      = var.glue_version
  # 2 workers minimo
  number_of_workers = var.glue_workers
  # tipos dos worker G.1X
  worker_type       = var.glue_worker_type

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.data.bucket}/${aws_s3_object.glue_script.key}"
  }

  default_arguments = {
    "--job-language" = "python"
    "--TempDir"      = "s3://${aws_s3_bucket.data.bucket}/tmp/"
    # Local de Download modulos python
    # https://docs.aws.amazon.com/pt_br/glue/latest/dg/getting-started-min-privs-job.html
    "--extra-py-files" = join(",", [
      "s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_common.py",
      "s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_to_timestamp.py",
      "s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_format_timestamp.py",
    ])


    # Útil pra debugar (CloudWatch)
    "--enable-metrics"                        = ""
    "--enable-continuous-cloudwatch-log"      = "true"
    "--continuous-log-logGroup"               = "/aws-glue/jobs"
    "--continuous-log-logStreamPrefix"        = var.glue_job_name
    "--job-bookmark-option"                   = "job-bookmark-enable"
  }


  execution_property {
    max_concurrent_runs = 1
  }
}


resource "aws_glue_trigger" "run_every_15m" {
  name = "${var.glue_job_name}-15min"
  type = "SCHEDULED"

  # a cada 15 minutos (UTC)
  schedule = "cron(0/15 * * * ? *)"

  actions {
    job_name = aws_glue_job.job.name
    # arguments = { "--EXTRA" = "valor" }  # opcional
  }

  start_on_creation = true
}

