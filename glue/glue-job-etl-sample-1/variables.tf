variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "meu-tutorial-glue-2"
}

variable "bronze_prefix" {
  type    = string
  default = "bronzer/"
}

variable "silver_prefix" {
  type    = string
  default = "silver/"
}

variable "scripts_prefix" {
  type    = string
  default = "scripts/"
}

variable "glue_job_name" {
  type    = string
  default = "relatorio-vendas-por-estados-canal-vendas-periodo"
}

variable "glue_version" {
  type    = string
  default = "5.0"
}

variable "glue_workers" {
  type    = number
  default = 2
}

variable "glue_worker_type" {
  type    = string
  default = "G.1X"
}
