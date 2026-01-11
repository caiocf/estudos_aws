# Kinesis Data Streams (PROVISIONED) com Terraform (2 shards)

Este projeto cria um **Amazon Kinesis Data Stream** em **modo provisionado (PROVISIONED)** usando Terraform, com **2 shards** por padrão.
No momento o Kinesis não faz parte dos serviço do AWS Free Tier, conforme a documentação https://aws.amazon.com/pt/free/?ams%23interactive-card-vertical%23pattern-data--662440127.filter=%257B%2522search%2522%253A%2522data%2520stream%2522%257D


## Arquitetura

Producer (AWS CLI / app) → **Kinesis Data Stream (2 shards)** → Consumer (AWS CLI / app)

```text
.
├─ main.tf
├─ variables.tf
├─ outputs.tf
├─ versions.tf
├─ terraform.tfvars.example
└─ README.md
```

---

## Pré-requisitos

- Terraform **>= 1.5**
- AWS CLI v2
- Credenciais AWS configuradas de uma das formas:
  - `aws configure` (perfil padrão), **ou**
  - variáveis de ambiente (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` se aplicável)
- Permissões IAM mínimas (exemplos):
  - `kinesis:CreateStream`, `kinesis:DescribeStreamSummary`, `kinesis:ListShards`
  - `kinesis:PutRecord`, `kinesis:PutRecords`
  - `kinesis:GetShardIterator`, `kinesis:GetRecords`

> ⚠️ Se sua conta estiver em “Free plan”/cadastro incompleto, alguns serviços podem ficar bloqueados no Console e via API.

---

## Variáveis (Terraform)

As principais variáveis ficam em `variables.tf`:

- `aws_region` — região AWS (ex: `us-east-1`)
- `stream_name` — nome do stream
- `shard_count` — número de shards (**default: 2**)
- `retention_hours` — retenção (em horas)
- `tags` — tags opcionais

---

## Como provisionar

1) Copie o arquivo de exemplo:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2) Edite `terraform.tfvars` e defina pelo menos `aws_region` e `stream_name`.

3) Aplique:

```bash
terraform init
terraform apply
```

Ao final, o Terraform exibirá outputs como o nome do stream.

---

## Como publicar dados (Producer)

Defina variáveis locais:

```bash
REGION="us-east-1"
STREAM_NAME="stream-output"
```

### Publicar 1 registro (put-record)

> O campo `--data` precisa estar em **base64**.

```bash
aws kinesis put-record   --stream-name "$STREAM_NAME"   --partition-key "pk-1"   --data "$(echo -n 'Data Entry 1' | base64)"   --region "$REGION"
```

### Publicar vários registros (put-records)

Crie um arquivo `records.json`:

```json
{
  "Records": [
    { "Data": "RGF0YSBFbnRyeSAy", "PartitionKey": "pk-2" },
    { "Data": "RGF0YSBFbnRyeSAz", "PartitionKey": "pk-3" }
  ],
  "StreamName": "stream-output"
}
```

Envie:

```bash
aws kinesis put-records   --cli-input-json file://records.json   --region "$REGION"
```

> Dica: `RGF0YSBFbnRyeSAy` é `"Data Entry 2"` em base64.

---

## Como ler dados (Consumer)

### 1) Descobrir o `ShardId`

```bash
aws kinesis list-shards   --stream-name "$STREAM_NAME"   --region "$REGION"
```

Saída típica contém algo como:

- `shardId-000000000000`
- `shardId-000000000001`

Escolha um `SHARD_ID` e exporte:

```bash
SHARD_ID="shardId-000000000000"
```

### 2) Obter o ShardIterator

#### Ler apenas os registros mais recentes (LATEST)

```bash
SHARD_ITERATOR=$(aws kinesis get-shard-iterator   --stream-name "$STREAM_NAME"   --shard-id "$SHARD_ID"   --shard-iterator-type LATEST   --region "$REGION"   --query 'ShardIterator'   --output text)

echo "$SHARD_ITERATOR"
```

#### Ler desde o início da retenção (TRIM_HORIZON)

```bash
SHARD_ITERATOR=$(aws kinesis get-shard-iterator   --stream-name "$STREAM_NAME"   --shard-id "$SHARD_ID"   --shard-iterator-type TRIM_HORIZON   --region "$REGION"   --query 'ShardIterator'   --output text)
```

### 3) Ler registros (get-records)

```bash
aws kinesis get-records   --shard-iterator "$SHARD_ITERATOR"   --region "$REGION"
```

A resposta retorna os registros e, geralmente, um `NextShardIterator`.
Para continuar lendo em loop, use o `NextShardIterator` em chamadas posteriores.

### 4) (Opcional) Decodificar o campo `Data` (base64)

Em Linux/macOS:

```bash
echo "RGF0YSBFbnRyeSAx" | base64 --decode
```

---

## Troubleshooting

### Erro: `SubscriptionRequiredException` / “needs a subscription for the service”
Geralmente indica **conta não ativada** (cadastro/identidade/pagamento pendente) ou **restrição do plano**.
Finalize o setup da conta no Console e/ou faça upgrade do plano para liberar o portfólio completo de serviços.

### `AccessDeniedException`
Suas credenciais não têm permissão para Kinesis. Verifique a policy/role/perfil em uso.

---

## Limpeza (destroy)

Para evitar custo, destrua os recursos ao final:

```bash
terraform destroy
```

---

## Observações (boas práticas / prova)

- Em **PROVISIONED**, você define `shard_count` e paga pela capacidade provisionada.
- A **PartitionKey** determina como os registros são distribuídos entre shards.
- Para elasticidade automática por throughput, considere **On-Demand** (não é o objetivo deste projeto).
