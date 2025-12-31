# Terraform — AWS Glue ETL (CSV → Parquet “Silver”) com agendamento, Bookmarks e Partition Projection (Athena)

Este repositório provisiona (via **Terraform**) um pipeline simples de **ETL em AWS Glue**:

- **Bronze (S3 / CSV)**: você coloca arquivos CSV em um prefixo de entrada no S3.
- **Glue Job (Spark)**: lê os CSVs, remove colunas, adiciona uma coluna de partição `dt` (data de ingestão) e grava em Parquet.
- **Silver (S3 / Parquet particionado)**: saída em `.../dt=YYYY-MM-DD/` com compressão.
- **Agendamento**: o job roda a cada **15 minutos** via **AWS Glue Trigger**.
- **Job Bookmarks**: evita reprocessar arquivos antigos quando o job roda novamente.
- **Partition Projection (Athena)**: a tabela no Athena/Glue Catalog pode ser configurada para **não precisar registrar partições** (sem crawler, sem MSCK REPAIR).

---

## 🧭 Arquitetura (alto nível)

1. Upload de CSV no S3 (prefixo **bronze**)
2. Glue Job (Spark) processa somente “novos” dados (Bookmarked)
3. Escrita em Parquet no S3 (prefixo **silver**) particionado por `dt`
4. Athena consulta a Silver via **Partition Projection**

---

## ✅ O que o Terraform cria

- 1 bucket S3 (ou reutiliza o nome definido) + “pastas”/prefixos (`bronze`, `silver`, `tmp`, `scripts`)
- Upload do script do Glue (`scripts/glue_job.py`) para o S3
- IAM Role/Policy para o Glue Job (acesso ao S3 + logs)
- AWS Glue Catalog **Database** (para padronização do projeto)
- AWS Glue **Job** (Spark) com parâmetros + Job Bookmarks habilitado
- AWS Glue **Trigger** agendado a cada 15 minutos (cron em UTC)

> Observação: **no modo Partition Projection**, este projeto NÃO cria/atualiza a tabela/partições no Glue Catalog durante a execução do Job.
> A tabela deve ser criada no Athena (ou via Terraform com `aws_glue_catalog_table`) com as propriedades de projection.

---

## 📦 Estrutura do repositório

- `main.tf` — Glue Job + Trigger
- `s3.tf` — bucket + upload do script
- `iam.tf` — role/policies do Glue
- `variables.tf` — variáveis do projeto
- `scripts/glue_job.py` — script ETL (CSV → Parquet particionado)

---

## 🔧 Pré-requisitos

- Terraform instalado
- Credenciais AWS configuradas (perfil ou env vars)
- Permissão para criar recursos: S3, IAM, Glue, CloudWatch Logs

---

## ▶️ Como executar

```bash
terraform init
terraform apply
```

Após o `apply`, envie um CSV para o prefixo **bronze** configurado (ex.: `bronzer/customers/`):

```bash
aws s3 cp ./customers.csv s3://<SEU_BUCKET>/<BRONZE_PREFIX>
```

O job roda automaticamente a cada 15 min. Para rodar na hora:

```bash
aws glue start-job-run --job-name <NOME_DO_JOB>
```

---

## 🧾 Parâmetros do Glue Job (Job Arguments)

O job recebe estes parâmetros (definidos em `default_arguments` no Terraform):

- `--BUCKET` — nome do bucket S3
- `--INPUT_PREFIX` — prefixo bronze (onde chegam CSVs)
- `--OUTPUT_PREFIX` — prefixo silver (onde serão gravados os Parquets)
- `--DB_NAME` e `--TABLE_NAME` — mantidos para padronização/log, mas **não atualizam o Catalog** no modo Projection

---

## 🧠 Sobre Job Bookmarks (somente “arquivos novos”)

O Job Bookmark é habilitado no job via:

- `--job-bookmark-option=job-bookmark-enable`

E, no script, a leitura do S3 usa `transformation_ctx`, requisito para bookmarks funcionarem corretamente.

Boas práticas para evitar reprocessamento inesperado:
- **não sobrescreva** a mesma key no S3 (use nomes únicos para cada arquivo)
- mantenha `max_concurrent_runs = 1`

---

## 🥈 Saída Silver (Parquet particionado)

O job escreve em:

- `s3://<bucket>/<silver_prefix>/dt=YYYY-MM-DD/`

A partição `dt` é a **data de ingestão (data da execução)**. Se você preferir particionar por data do arquivo (ex.: no nome), adapte o script.

---

## 🔎 Criando a tabela no Athena com Partition Projection

A Partition Projection evita “registrar partições” no Catalog. Você define as regras de partição na **propriedade da tabela**.

Abaixo um exemplo (ajuste **colunas** conforme seu schema final). Execute no Athena:

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS tutorial_glue.cliente_campos_dropados (
  -- TODO: ajuste as colunas reais do seu parquet
  customer_id string,
  name        string,
  email       string
)
PARTITIONED BY (dt string)
STORED AS PARQUET
LOCATION 's3://<SEU_BUCKET>/<SILVER_PREFIX>/'
TBLPROPERTIES (
  'projection.enabled'='true',

  'projection.dt.type'='date',
  'projection.dt.format'='yyyy-MM-dd',
  'projection.dt.range'='2025-01-01,NOW',
  'projection.dt.interval'='1',
  'projection.dt.interval.unit'='DAYS',

  'storage.location.template'='s3://<SEU_BUCKET>/<SILVER_PREFIX>/dt=${dt}/'
);
```

Exemplo de query:

```sql
SELECT *
FROM tutorial_glue.cliente_campos_dropados
WHERE dt = date_format(current_date, '%Y-%m-%d')
LIMIT 10;
```

---

## 🧪 Troubleshooting rápido

- **Nada foi processado**: verifique se existe arquivo em `INPUT_PREFIX` e se o job está executando (CloudWatch Logs).
- **Reprocessou arquivo antigo**: você sobrescreveu a mesma key no S3 ou resetou o bookmark.
- **Athena não encontra dados**: confira `LOCATION` e `storage.location.template` (precisam bater com o prefixo real).

---

## 🧹 Cleanup

```bash
terraform destroy
```

---

## 📚 Referências (docs oficiais)

- AWS Glue — Job Bookmarks: https://docs.aws.amazon.com/glue/latest/dg/programming-etl-connect-bookmarks.html
- AWS Glue — Tracking processed data (bookmarks): https://docs.aws.amazon.com/glue/latest/dg/monitor-continuations.html
- AWS Glue — Job parameters (`--job-bookmark-option`): https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-glue-arguments.html
- Amazon Athena — Partition Projection (visão geral): https://docs.aws.amazon.com/athena/latest/ug/partition-projection.html
- Amazon Athena — Como configurar (pt-BR): https://docs.aws.amazon.com/pt_br/athena/latest/ug/partition-projection-setting-up.html
