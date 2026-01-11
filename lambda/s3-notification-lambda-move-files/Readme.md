# S3 Event → Lambda → Move CSV (Terraform)

Este projeto provisiona, via **Terraform**, uma automação simples:

1. Um **upload de arquivo `.csv`** no **bucket de origem**
2. Dispara uma **AWS Lambda** via **S3 Event Notification**
3. A Lambda **move** o arquivo para o **bucket de destino** (copia e depois deleta no bucket de origem)

A Lambda recebe o **nome do bucket de destino** por **variável de ambiente** (`DESTINATION_BUCKET`).

---

## 🧩 Arquitetura

```
S3 (source bucket)  --(ObjectCreated:*.csv)-->  Lambda  --copy-->  S3 (destination bucket)
                                                    └--delete--> S3 (source bucket)
```

**Filtro do evento:** somente arquivos com sufixo **`.csv`**.

---

## 🏗️ Recursos provisionados

- **2 buckets S3**
  - `source` (origem)  
  - `destination` (destino)
- **AWS Lambda** (Python 3.12) para mover o objeto
- **IAM Role/Policy** mínima para:
  - `GetObject` + `DeleteObject` no bucket de origem
  - `PutObject` no bucket de destino
  - Logs no CloudWatch
- **S3 Bucket Notification** para invocar a Lambda em `s3:ObjectCreated:*` com `filter_suffix = ".csv"`

> Observação: os buckets usam `force_destroy = true` para facilitar laboratório (o Terraform consegue destruir mesmo com objetos dentro).


---

## ✅ Pré-requisitos

- Terraform **>= 1.5**
- AWS CLI configurada (profile/SSO/keys)
- Permissões para criar/alterar:
  - S3 (buckets, notifications, objects)
  - Lambda
  - IAM (role/policies)
  - CloudWatch Logs

> **Importante:** nomes de bucket S3 são **globais**.  
> Para evitar colisão, este projeto **anexa automaticamente o Account ID** ao nome informado:
>
> - Origem final: `"<source_bucket_name>-<account_id>"`
> - Destino final: `"<destination_bucket_name>-<account_id>"`

---

## ⚙️ Variáveis (inputs)

| Variável | Descrição | Exemplo |
|---|---|---|
| `aws_region` | Região AWS | `us-east-1` |
| `source_bucket_name` | **Prefixo** do bucket de origem | `meu-bucket-origem-csv` |
| `destination_bucket_name` | **Prefixo** do bucket de destino | `meu-bucket-destino-csv` |
| `lambda_name` | Nome da função | `move-csv-between-buckets` |

Exemplo de `terraform.tfvars`:

```hcl
aws_region              = "us-east-1"
source_bucket_name      = "meu-bucket-origem-csv"
destination_bucket_name = "meu-bucket-destino-csv"
lambda_name             = "move-csv-between-buckets"
```

---

## 🚀 Como executar

```bash
terraform init
terraform plan
terraform apply
```

Ao final do `apply`, você verá nos **outputs** o nome final dos buckets e da Lambda.

---

## 🧪 Como testar

### Opção A) Teste automático (já vem no Terraform)

Este projeto possui um `aws_s3_object` que faz upload do arquivo **`customer.csv`** para o bucket de origem durante o `terraform apply`.

- O upload dispara a Lambda
- A Lambda move o arquivo para o bucket de destino

> Nota: como o Terraform “gerencia” esse objeto e a Lambda o deleta do bucket de origem, pode haver **drift** (o Terraform vai querer recriar o objeto no próximo `plan/apply`).  
> Se você preferir evitar isso, remova o resource `aws_s3_object "upload_csv"` do `main.tf` e use a Opção B abaixo.

### Opção B) Teste manual (recomendado para uso real)

1) Faça upload de um CSV no bucket de origem:

```bash
aws s3 cp customer.csv s3://<SOURCE_BUCKET_FINAL>/customer.csv --region <REGION>
```

2) Verifique se o arquivo apareceu no bucket de destino:

```bash
aws s3 ls s3://<DESTINATION_BUCKET_FINAL>/ --region <REGION>
```

3) (Opcional) Confira logs da execução:

- CloudWatch Logs → Log group: `/aws/lambda/<lambda_name>`

---

## 🔍 Como a Lambda “move” o arquivo

S3 não tem operação nativa “move”. O padrão é:

1. `CopyObject` para o bucket de destino
2. `DeleteObject` no bucket de origem

O nome do bucket de destino vem da variável de ambiente:

- `DESTINATION_BUCKET`

---

## 🧹 Limpeza

```bash
terraform destroy
```

---

## 📌 Dicas

- Se quiser mover para um prefixo no destino (ex.: `landing/`), basta alterar a `Key` no `copy_object`.
- Se seus objetos podem ter espaços/caracteres especiais, a Lambda já faz `unquote_plus` no `object.key`.

