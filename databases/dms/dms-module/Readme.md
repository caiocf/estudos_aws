# Módulo AWS DMS Terraform

Este módulo habilita a criação de replicação usando o AWS Database Migration Service (DMS).

## Recursos Criados

- Criação das roles bases:
  - `dms-access-for-endpoint`
  - `dms-cloudwatch-logs-role`
  - `dms-vpc-role`
- Criação do AWS DMS Endpoint (source e target)
- Criação da instância de replicação
- Criação de task de replicação
- Criação de KMS para instância de replicação
- Criação de subnet group para o DMS

## Parâmetros do Módulo

| Nome da Variável                             | Descrição                                       | Valor Padrão      |
|----------------------------------------------|-------------------------------------------------|-------------------|
| `source_database_name`                       | Nome do database de origem                      | N/A               |
| `source_database_username`                   | Username do database de origem                  | N/A               |
| `source_database_password`                   | Password do database de origem                  | N/A               |
| `source_database_engine`                     | Engine do database de origem                    | N/A               |
| `source_database_host`                       | Host do database de origem                      | N/A               |
| `source_database_port`                       | Port do database de origem                      | N/A               |
| `source_database_extra_connection_attributes`| Atributos extras do database de origem          | N/A               |
| `target_database_name`                       | Nome do database de destino                     | N/A               |
| `target_database_username`                   | Username do database de destino                 | N/A               |
| `target_database_password`                   | Password do database de destino                 | N/A               |
| `target_database_engine`                     | Engine do database de destino                   | N/A               |
| `target_database_host`                       | Host do database de destino                     | N/A               |
| `target_database_port`                       | Port do database de destino                     | N/A               |
| `target_database_extra_connection_attributes`| Atributos extras do database de destino         | N/A               |
| `replication_instance_class`                 | Classe da instância de replicação               | `dms.t2.micro`    |
| `replication_instance_storage`               | Tamanho do storage da instância de replicação   | 20                |
| `replication_instance_version`               | Versão Engine da instância de replicação        | `3.5.2`           |
| `dms_vpc_security_group_ids`                 | Listagem de security group IDs                  | N/A               |
| `dms_vpc_subnet_ids`                         | Listagem de subnets da VPC                      | N/A               |
| `dms_task_migration_type`                    | Tipo de migração                                | `full-load-and-cdc`|
| `application`                                | Nome da aplicação                               | N/A               |


