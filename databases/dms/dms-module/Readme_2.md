Este modulo que habilita criação de replicação usando o AWS DMS:

Recursos criados:
criação das roles bases: dms-access-for-endpoint,dms-cloudwatch-logs-role,dms-vpc-role
criação aws dms endpoint source e target
criação instancia de replicação
criação de task de replicação
criação kms para instancia de replicação
criação subnet group dms

o modulo recebe como parametos a tabela abaixo:

# DMS Source Endpoint
variable "source_database_name" {
type = string
description = "Nome do database de origem"
}
variable "source_database_username" {
type = string
description = "username do database de origem"
}
variable "source_database_password" {
type = string
description = "password do database de origem"
}

variable "source_database_engine" {
type = string
description = "Engine do database de origem"
}

variable "source_database_host" {
type = string
description = "Host do database de origem"
}

variable "source_database_port" {
type = number
description = "Port do database de origem"
}

variable "source_database_extra_connection_attributes" {
type = string
description = "Atributos Extras do database de origem"
}
# DMS Target Endpoint
variable "target_database_name" {
type = string
description = "Nome do database de destino"
}
variable "target_database_username" {
type = string
description = "username do database de destino"
}
variable "target_database_password" {
type = string
description = "password do database de destino"
}

variable "target_database_engine" {
type = string
description = "Engine do database de destino"
}

variable "target_database_host" {
type = string
description = "Host do database de destino"
}

variable "target_database_port" {
type = number
description = "Port do database de destino"
}

variable "target_database_extra_connection_attributes" {
type = string
description = "Atributos Extras do database de origem"
}

## Instance Replication
variable "replication_instance_class" {
type = string
description = "Classe da instancia de replicacao"
default = "dms.t2.micro"
}

variable "replication_instance_storage" {
type = number
description = "Tamanho do storage da instancia de replicacao"
default = 20
}

variable "replication_instance_version" {
type = string
description = "Versão Engine da instancia de replicacao"
default = "3.5.2"
}

variable "dms_vpc_security_group_ids" {
type = list(string)
description = "Listagem de security group ID"
}

variable "dms_vpc_subnet_ids" {
type = list(string)
description = "Listagem de subnets da VPC"
}

variable "dms_task_migration_type" {
type = string
description = "Tipo de migracao: full-load-and-cdc ou full-load ou full-load-and-cdc"
default = "full-load-and-cdc"
}

variable "application" {
type = string
description = "Nome aplicacao"
}

