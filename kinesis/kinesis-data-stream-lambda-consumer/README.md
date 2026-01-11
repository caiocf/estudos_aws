# Kinesis Data Streams (PROVISIONED) + Lambda Consumer + S3 (Terraform)

Este projeto provisiona na AWS, via **Terraform**:

- **Amazon Kinesis Data Stream** em modo **PROVISIONED** (por padrão, **2 shards**)
- **AWS Lambda** como **consumer** do stream (Event Source Mapping)
- **Amazon S3 bucket** para persistir os eventos consumidos

A Lambda lê os registros do Kinesis (payload em base64), decodifica e grava cada registro como um arquivo `.txt` no S3.

> ⚠️ **Custo**: Kinesis Data Streams **não é elegível ao AWS Free Tier**. Faça testes e destrua os recursos ao final (`terraform destroy`).

---

## Arquitetura

```text
Producer (AWS CLI / App)
        |
        v
Kinesis Data Stream (PROVISIONED: 2 shards)
        |
        v
Lambda Consumer (Kinesis event source mapping)
        |
        v
S3 Bucket (arquivos .txt por registro)
```

---

## Estrutura do projeto

```text
.
├─ main.tf
├─ variables.tf
├─ outputs.tf
├─ versions.tf
├─ terraform.tfvars.example
└─ lambda/
   └─ lambda_function.py
```

---

## Pré-requisitos

- Terraform >= 1.5
- AWS CLI configurado (`aws configure`) **ou** variáveis de ambiente (`AWS_ACCESS_KEY_ID`, etc.)
- Permissões para criar: Kinesis, Lambda, IAM Role/Policy, S3

---

## Configuração

1) Copie o arquivo de exemplo e edite os valores:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2) Edite `terraform.tfvars` e defina um `s3_bucket_name` **globalmente único**.

---

## Deploy

```bash
terraform init
terraform apply
```

Ao final, anote os outputs (nome do stream, bucket, etc.).

---

## Publicar eventos no Kinesis (Producer)

### PutRecord (1 registro)

```bash
aws kinesis put-record \
  --stream-name stream-output \
  --partition-key "PartitionKey1" \
  --data $(echo -n "hello kinesis" | base64) \
  --region us-east-1
```

### PutRecord (outro registro)

```bash
aws kinesis put-record \
  --stream-name stream-output \
  --partition-key "PartitionKey2" \
  --data $(echo -n "event 2" | base64) \
  --region us-east-1
```

> Dica: a `partition-key` influencia em qual shard o registro cai (hash).

---

## Verificar a gravação no S3 (resultado do Consumer)

A Lambda grava cada registro como: `{partitionKey}-{timestamp}.txt`.

Liste os objetos no bucket:

```bash
aws s3 ls s3://SEU_BUCKET_AQUI --region us-east-1
```

Baixe um arquivo e veja o conteúdo:

```bash
aws s3 cp s3://SEU_BUCKET_AQUI/PartitionKey1-YYYY-MM-DD-HHMMSS.txt - --region us-east-1
```

---

## Observabilidade (logs da Lambda)

Verifique logs no CloudWatch Logs (log group `/aws/lambda/<lambda_name>`):

```bash
aws logs describe-log-streams \
  --log-group-name "/aws/lambda/kinesis-to-s3-consumer" \
  --region us-east-1
```

---

## Limpeza (evitar custo)

```bash
terraform destroy
```

---

## Notas importantes (mental model rápido)

- **Kinesis não “apaga” dados quando você consome**. A retenção é por tempo (`retention_hours`).
- **Checkpoint** é responsabilidade do consumer/biblioteca (ex.: KCL usa DynamoDB).  
  Para Lambda com event source mapping, o avanço é gerenciado pelo serviço.
- Em **PROVISIONED**, você paga por capacidade provisionada (shard-hours).
