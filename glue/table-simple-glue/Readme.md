# Estudos AWS: Glue Data Catalog com Partition Projection

Este repositório contém os arquivos necessários para provisionar uma infraestrutura de dados na AWS utilizando **Terraform**, com foco na criação de uma tabela no **AWS Glue** otimizada com **Partition Projection**.

O objetivo deste projeto é demonstrar como configurar a virtualização de partições para que arquivos carregados no **Amazon S3** fiquem disponíveis para consulta no **Amazon Athena** de forma instantânea, eliminando a dependência de processos manuais ou Glue Crawlers para o registro de partições.

## 🏗️ Recursos Provisionados

*
**S3 Bucket**: Armazenamento dos dados em formato Parquet com criptografia **AES256**.


*
**Glue Catalog Database**: Banco de dados `db_source_clientes_dispositivo_sor_01`.


*
**Glue Catalog Table**: Tabela `dispositivo_autorizado` com esquema de colunas para gestão de dispositivos.


*
**IAM Role & Policy**: Permissões de leitura e escrita para o serviço Glue no bucket específico.


*
**Partition Projection**: Configuração dinâmica para a partição `anomesdia` no formato `yyyyMMdd`.



## 🚀 Como Utilizar

### 1. Preparação dos Dados (Python)

Antes de aplicar o Terraform, gere o arquivo Parquet de amostra utilizando o script disponível na pasta de scripts:

```shell
# Entre na pasta do script de dados
cd script_gera_dados/

# Crie e ative o ambiente virtual
python -m venv venv
# Windows: venv\Scripts\activate | Linux/macOS: source venv/bin/activate

# Instale as dependências e gere o arquivo
pip install -r requirements.txt
python gera_dados_parquet.py

```

O script gera o arquivo `dados_dispositivo_amostra_20.parquet` com os dados necessários para o teste inicial.

### 2. Provisionamento da Infraestrutura (Terraform)

Retorne à raiz do projeto e execute os comandos abaixo para criar os recursos:

```shell
terraform init
terraform plan
terraform apply

```

### 3. Validação no Amazon Athena

Após o upload bem-sucedido do arquivo pelo Terraform , você pode consultar os dados imediatamente no console do Athena:

```sql
SELECT * FROM "db_source_clientes_dispositivo_sor_01"."dispositivo_autorizado" 
WHERE anomesdia = '20231027' 
LIMIT 20;

```

>
> **Nota**: No console do Glue, a aba de partições exibirá **Partitions (0)**. Isso é o comportamento esperado do **Partition Projection**, onde as partições são calculadas em tempo de execução e não persistidas no catálogo.
>
>

## 🗑️ Limpeza de Recursos

Para evitar custos desnecessários com os recursos criados (Bucket S3, Roles e Glue Database), execute o comando de destruição:

```shell
terraform destroy

```

---

## 🛠️ Detalhes Técnicos (Interpolação Dinâmica)

O projeto utiliza uma estratégia de nomeação dinâmica no arquivo `main.tf` para garantir a unicidade dos recursos entre diferentes contas AWS sem a necessidade de hardcode:

*
**`local.control_account_id`**: Utiliza a função `coalesce` para priorizar o valor da variável `var.control_account`. Caso o valor seja nulo, o Terraform captura automaticamente o ID da conta atual via `data.aws_caller_identity`.


*
**`local.sor_s3bucket`**: Segue a mesma lógica de priorização, construindo o nome do bucket dinamicamente como `corp-sor-sa-east-1-${account_id}` caso nenhum nome seja fornecido via variável.


*
**Localização dos Dados**: A propriedade `storage.location.template` mapeia as pastas do S3 automaticamente utilizando o padrão de partição configurado: `s3://${local.sor_s3bucket}/${var.sor_table_name}/anomesdia=$${anomesdia}`.



