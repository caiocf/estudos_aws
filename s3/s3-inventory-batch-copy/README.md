# S3 Inventory + S3 Batch Operations com Terraform

Projeto educacional para demonstrar como copiar **objetos existentes** de um bucket Amazon S3 para outro bucket em uma atividade **one-time**, usando:

- **Amazon S3 Inventory** para gerar a lista dos objetos existentes.
- **Amazon S3 Batch Operations** para copiar objetos em massa.
- **Completion report** para auditoria ao final do job.

> Cenário de prova AWS Data Engineer Associate: quando a questão fala em **milhões de objetos existentes**, **cópia única** e **relatório de auditoria**, pense em **S3 Inventory + S3 Batch Operations**.

---

## Arquitetura

```text
S3 Bucket origem
      |
      | 1. S3 Inventory gera lista de objetos
      v
S3 Bucket inventory
      |
      | 2. Manifest é usado como entrada
      v
S3 Batch Operations
      |
      | 3. Copia objetos
      v
S3 Bucket destino
      |
      | 4. Gera relatório de conclusão
      v
S3 Bucket reports
```

---

## O que este projeto cria

Este Terraform cria:

1. Bucket S3 de origem.
2. Bucket S3 de destino.
3. Bucket S3 para armazenar o relatório do S3 Inventory.
4. Bucket S3 para armazenar o relatório de conclusão do Batch Operations.
5. Objetos de exemplo no bucket de origem.
6. Configuração de S3 Inventory no bucket de origem.
7. IAM Role para o S3 Batch Operations.
8. Opcionalmente, o job de S3 Batch Operations para copiar os objetos.

---

## Por que usar S3 Inventory?

O S3 Inventory gera uma lista dos objetos existentes em um bucket.

Essa lista pode conter dados como:

- Bucket
- Key
- VersionId
- Size
- LastModifiedDate
- StorageClass
- ETag

Ela é útil porque o S3 Batch Operations precisa de um **manifest** para saber quais objetos serão processados.

---

## Por que usar S3 Batch Operations?

O S3 Batch Operations executa ações em larga escala sobre muitos objetos S3.

Exemplos de operações:

- Copiar objetos
- Restaurar objetos do Glacier
- Aplicar tags
- Invocar Lambda
- Aplicar ACLs

Neste projeto, usamos Batch Operations para copiar objetos existentes do bucket de origem para o bucket de destino.

---

## S3 Batch Operations vs S3 Replication

| Requisito | Melhor opção |
|---|---|
| Copiar objetos existentes uma única vez | S3 Batch Operations |
| Replicar novos objetos continuamente | S3 Replication / CRR |
| Gerar lista de objetos | S3 Inventory |
| Obter métricas e tendências de uso | S3 Storage Lens |

---

## Pré-requisitos

Você precisa ter instalado:

- Terraform >= 1.6
- AWS CLI configurado
- Credenciais AWS com permissão para criar S3 buckets, IAM roles e S3 Batch Operations

Confirme sua identidade AWS:

```bash
aws sts get-caller-identity
```

---

## Como usar

### 1. Clone o projeto

```bash
git clone https://github.com/SEU-USUARIO/s3-inventory-batch-copy-terraform.git
cd s3-inventory-batch-copy-terraform
```

### 2. Configure variáveis

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edite o arquivo `terraform.tfvars` se quiser mudar a região ou o nome do projeto.

### 3. Inicialize o Terraform

```bash
terraform init
```

### 4. Primeiro apply

No primeiro apply, deixe:

```hcl
enable_batch_job = false
```

Execute:

```bash
terraform apply
```

Esse passo cria os buckets, os objetos de exemplo e configura o S3 Inventory.

---

## Etapa importante: aguardar o S3 Inventory

O S3 Inventory **não é gerado imediatamente**.  
Mesmo com frequência `Daily`, pode levar até 48 horas para o primeiro relatório aparecer.

Quando o relatório aparecer no bucket de inventory, localize o arquivo `manifest.json`.

Exemplo de busca:

```bash
aws s3 ls s3://NOME-DO-BUCKET-INVENTORY/inventory/ --recursive | grep manifest.json
```

Exemplo de key encontrada:

```text
inventory/s3-inventory-batch-copy-demo-abc12345-source/all-objects-inventory/2025-01-01T00-00Z/manifest.json
```

Copie essa key.

---

## 5. Criar o job de S3 Batch Operations

Atualize o `terraform.tfvars`:

```hcl
enable_batch_job = true

inventory_manifest_key = "inventory/s3-inventory-batch-copy-demo-abc12345-source/all-objects-inventory/2025-01-01T00-00Z/manifest.json"
```

Execute novamente:

```bash
terraform apply
```

O Terraform criará um job do S3 Batch Operations.

---

## 6. Validar a cópia

Liste os objetos no bucket de destino:

```bash
aws s3 ls s3://NOME-DO-BUCKET-DESTINO --recursive
```

Veja o relatório de conclusão:

```bash
aws s3 ls s3://NOME-DO-BUCKET-REPORTS/batch-reports/ --recursive
```

---

## Limpeza

Para remover os recursos:

```bash
terraform destroy
```

> Os buckets estão com `force_destroy = true`, então os objetos de demonstração serão removidos junto com os buckets.

---

## Pontos importantes para certificação AWS

### Quando usar S3 Inventory + Batch Operations?

Use quando a questão mencionar:

- Muitos objetos existentes.
- Atividade única.
- Cópia, tagueamento, restore ou outra operação em massa.
- Necessidade de relatório de auditoria.

### Quando usar S3 Cross-Region Replication?

Use quando a questão mencionar:

- Replicação contínua.
- Novos objetos.
- Alta disponibilidade entre regiões.
- Compliance de replicação.

### Quando usar S3 Storage Lens?

Use quando a questão mencionar:

- Métricas de uso.
- Tendências de armazenamento.
- Otimização de custos.
- Visibilidade organizacional.

---

## Observações práticas

Este projeto é educacional. Em produção, avalie:

- Criptografia com SSE-KMS.
- Políticas de menor privilégio.
- Versionamento e replicação.
- Custos de S3 Inventory, Batch Operations, requests e armazenamento.
- Restrições organizacionais via SCP.
- Logs com CloudTrail.
- Ciclo de vida dos relatórios gerados.

---

## Resumo mental

```text
Objetos existentes + one-time + audit report
= S3 Inventory + S3 Batch Operations
```
