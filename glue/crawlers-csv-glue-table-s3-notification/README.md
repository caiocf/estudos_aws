# Terraform — AWS Glue Data Catalog (SOR) com S3 → SQS (Event Mode)

Infraestrutura como código (IaC) em **Terraform** para provisionar um “mini data lake” na AWS com:

- **Amazon S3** (camada SOR / landing)
- **AWS Glue Data Catalog** (database + tabela(s) via crawler)
- **AWS Glue Crawler** em **modo incremental por eventos** (*S3 Event Notifications* → **SQS**)  
- **IAM** (role e policies mínimas para o crawler)
- Upload de um **CSV de exemplo** para validar o fluxo end-to-end


> **Importante:** `event_queue_arn` **não dispara** o crawler automaticamente. Ele apenas habilita o **modo por eventos**, no qual o crawler **consome mensagens da SQS durante uma execução** (por *schedule* ou execução manual) para identificar o que mudou e evitar varrer todo o S3.
> Se você adicionar um novo CSV **dentro de uma partição já conhecida** e o **schema** permanecer igual, ele poderá ser lido normalmente pelos consumidores (ex.: Athena/Spark) pelo `LOCATION` da tabela — sem necessidade de rodar o crawler.
> Você normalmente precisa executar o crawler quando houver **criação de novas partições** (ex.: novo `dt=.../`) que precisam ser registradas no catálogo (a menos que você use *partition projection*), ou quando houver **mudanças de schema** (ex.: adicionar coluna, remover coluna, alterar tipo).

---

## 🧭 Visão geral

O objetivo é manter o **Glue Data Catalog** atualizado a partir de arquivos CSV no S3:

1. Um arquivo é enviado para o S3 (ex.: `customers/customers_1.csv` dentro de partições por `ano/mes/dia`)
2. O S3 publica um evento na fila **SQS**
3. Quando o **Glue Crawler** roda, ele lê a **SQS** para descobrir o que mudou e atualizar o catálogo

---

## 🏗️ Arquitetura (alto nível)

```
Upload CSV
   │
   ▼
S3 bucket (SOR) ──(Event Notification)──► SQS (event queue)
   │                                         │
   │                                         ▼
   └──────────────► Glue Crawler (CRAWL_EVENT_MODE) ──► Glue Data Catalog (DB/Tables)
```

---

## 📦 O que este projeto cria

### S3
- Bucket SOR (nome por padrão: `corp-sor-sa-east-1-<account_id>` — pode ser sobrescrito por variável)
- **Public Access Block** habilitado
- Criptografia server-side padrão (`AES256`)
- Upload de amostra: `customers_1.csv` em um caminho particionado:
  - `customers/ano=2023/mes=10/dia=28/customers_1.csv`

### SQS
- Fila **Standard** para eventos do S3
- **Queue policy** permitindo:
  - `s3.amazonaws.com` fazer `SendMessage` (restrito por `SourceArn` do bucket e `SourceAccount`)
  - a role do Glue consumir a fila (`ReceiveMessage`, `DeleteMessage`, etc.)

### Glue
- `aws_glue_catalog_database` (DB do SOR)
- `aws_glue_crawler` apontando para o prefixo do dataset no S3
- `recrawl_policy` em **`CRAWL_EVENT_MODE`** (incremental por eventos)
- `schema_change_policy`:
  - `update_behavior = "UPDATE_IN_DATABASE"` (atualiza metadados no catálogo quando houver mudanças)
  - `delete_behavior = "LOG"` (não apaga metadados; apenas registra em log)

### IAM
- Role do crawler com trust para `glue.amazonaws.com`
- Anexo da policy gerenciada `AWSGlueServiceRole`
- Policies adicionais para:
  - Ler/listar o bucket/prefixo do S3
  - Consumir mensagens da fila SQS

---

## ✅ Pré-requisitos

- Terraform instalado (o projeto define `required_version` em `version.tf`)
- AWS CLI configurada (ou variáveis de ambiente com credenciais)
- Permissões na conta AWS para criar S3/SQS/IAM/Glue

---

## 🚀 Como executar

```bash
terraform init
terraform plan
terraform apply
```

Após o `apply`, você pode:

- Aguardar o **schedule** (de 15 em 15 minutos) do crawler (de acordo com o estiver configurado no seu `main.tf`), **ou**
- Iniciar manualmente no Console do Glue, **ou**
- Via CLI:

```bash
aws glue start-crawler --name <NOME_DO_CRAWLER>
```

---

## 🔧 Variáveis principais

As variáveis ficam em `variable.tf`. As mais comuns:

- `aws_region`: região do provider AWS
- `sor_s3bucket`: **opcional** — sobrescreve o nome do bucket SOR
- `sor_db_name_source`: nome do Glue Catalog Database
- `sor_table_name`: prefixo/pasta do dataset (padrão: `customers`)
- `control_account`: opcional (ID de conta de controle, se você estiver simulando multi-account)

## 📤 Outputs

Após `terraform apply`, veja:

- `bucket_name`
- `queue_url`
- `queue_arn`

---

## 🧪 Como validar rapidamente

1. Abra o bucket e confirme o arquivo de amostra em:
   `customers/ano=2023/mes=10/dia=28/customers_1.csv`
2. Verifique se a SQS recebeu mensagens (métricas/console).
3. Execute o crawler e confirme no **Glue Data Catalog**:
   - Database criado
   - Tabela(s) criada(s)
   - Partições detectadas (dependendo da classificação e do crawler)

---

## 🧹 Cleanup

```bash
terraform destroy
```

---

