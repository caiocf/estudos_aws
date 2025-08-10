# MSK Simples – Terraform

Provisiona um ambiente **Amazon MSK (Apache Kafka 3.6.0)** “simples”, com:

* **VPC + subnets públicas**, IGW e rota
* **MSK provisionado** (2 brokers), criptografia em trânsito (TLS) e em repouso (KMS)
* **Autenticação**: **SASL/SCRAM** (Secrets Manager + associação) **e** **SASL/IAM**
* **Open Monitoring (Prometheus)** e **CloudWatch Logs**
* **Autoescalabilidade de armazenamento** (Application Auto Scaling – alvo de utilização de disco)
* **Configuration (Rev.3)** com parâmetros de broker (server.properties)

> ⚠️ Por padrão o cluster nasce com **acesso público desativado**. Para testar do seu computador, habilite **temporariamente** o público (instruções abaixo) ou rode os clientes numa **EC2** na mesma VPC.

---

## Estrutura

```
.
├─ data.tf                  # datasources auxiliares
├─ providers.tf             # provider AWS (região via var)
├─ variables.tf             # variáveis do projeto
├─ version.tf               # required_version / providers
├─ vpc.tf                   # VPC, subnets, igw, rotas
├─ security.tf              # SG do MSK (9094/9098)
├─ main.tf                  # MSK Cluster, KMS, logs, config Rev3, autoscaling storage
├─ output.tf                # outputs úteis
├─ connectivity.json        # enable public access (CLI)
├─ Readme.md                # este arquivo
└─ Readme_Configs_KafkaMsk.md # explicação detalhada da Rev3 (server.properties)
```

---

## Pré-requisitos

* Terraform ≥ 1.6
* Credenciais AWS válidas (perfil/variáveis)
* Permissões para: VPC/EC2, MSK, KMS, Secrets Manager, CloudWatch Logs, Application Auto Scaling
* (Opcional) EC2 para testes dentro da VPC

---

## Variáveis principais (resumo)

Defina em `terraform.tfvars` (exemplo), caso deseje e passei via parametro o arquivo para o comando terraform:

```hcl
region        = "us-east-1"
project_name  = "outbox-cdc-msk"

# MSK
kafka_version        = "3.6.0"
broker_instance_type = "kafka.m5.large"
public_access_type   = "DISABLED" # criação exige DISABLED; depois você pode atualizar p/ SERVICE_PROVIDED_EIPS

# SCRAM
msk_scram_username = "appclient"  # o Secret será AmazonMSK_appclient (KMS CMK custom)
```

> Dica: As variaveis tem os valores padrões acima já.

---

## Como usar

```bash
terraform init 
terraform plan 
terraform apply
```

**Outputs** úteis:

* `cluster_arn`
* `zookeeper_connect_string` (apenas informativo)
* (use o CLI para pegar os **bootstrap brokers endpoint** reais ou olhe output do terraform)

```bash
aws kafka get-bootstrap-brokers \
  --cluster-arn $(terraform output -raw cluster_arn) \
  --region $(terraform output -raw region 2>/dev/null || echo us-east-1)
```

---

## Autenticação

### SASL/SCRAM (porta 9094)

* O projeto cria:

   * **KMS CMK** para secrets (MSK não aceita a default key)
   * **Secret** `AmazonMSK_<username>` no Secrets Manager
   * **Associação** do secret ao cluster (`aws_msk_scram_secret_association`)

### SASL/IAM (porta 9098)

* Habilitado no cluster (client\_authentication.sasl.iam = true)
* **Importante**: IAM **é AND**:

   1. **IAM policy** na role/usuário (permissões `kafka-cluster:*`)
   2. **MSK Cluster Policy** permitindo seu principal no **cluster**
      (opcional neste projeto; inclua se for usar IAM de fato)
   3. `authorizer.class.name=software.amazon.msk.auth.iam.IAMAuthorizer` e
      `allow.everyone.if.no.acl.found=false` na **Configuration** (Rev.3)

Você pode gerenciar a Cluster Policy via Terraform com `aws_msk_cluster_policy` se quiser travar por tópicos/prefixos.

---

## Configuration (Rev.3)

A configuração **Rev.3** (em `main.tf`) aplica parâmetros como:

* `auto.create.topics.enable = true` *(laboratório)*
* `default.replication.factor = 2`
* `log.retention.hours = 168`
* `min.insync.replicas = 1`
* `num.io.threads = 8`, `num.network.threads = 5`
* `num.partitions = 2`
* `unclean.leader.election.enable = true`
* `zookeeper.session.timeout.ms = 18000`
* `allow.everyone.if.no.acl.found = false`
* (se IAM): `authorizer.class.name = software.amazon.msk.auth.iam.IAMAuthorizer`

> Produção: veja recomendações no `Readme_Configs_KafkaMsk.md` (ex.: desabilitar auto-create, RF=3, minISR=2, unclean=false).

---

## Autoescalabilidade de armazenamento

Configurada via **Application Auto Scaling**:

* Alvo: `kafka:broker-storage:VolumeSize`
* `min_capacity` = tamanho atual por broker
* `max_capacity` = teto (ex.: 500 GiB)
* Política **TargetTracking** com `KafkaBrokerStorageUtilization` (ex.: 80%)

Recurso: `aws_appautoscaling_target` + `aws_appautoscaling_policy` em `main.tf`.

---

## Habilitar acesso público (temporário)

**Criação** deve ser com `DISABLED`. Depois, para testar do seu PC:

1. **Atualize a Configuration (já está ok)**:
   `allow.everyone.if.no.acl.found=false` (e, se IAM, `authorizer.class.name=...IAMAuthorizer`)

2. **Habilite público via CLI** (use `connectivity.json`):

```bash
REGION=us-east-1
CLUSTER_ARN=$(terraform output -raw cluster_arn)

# Descobrir o ARN do cluster (se você já souber, pode pular)
aws kafka list-clusters-v2 --region $REGION \
  --query "ClusterInfoList[].ClusterArn" --output text
  
CURRENT_VERSION=$(aws kafka describe-cluster-v2 --region $REGION --cluster-arn "$CLUSTER_ARN" --query "ClusterInfo.CurrentVersion" --output text)

aws kafka update-connectivity \
  --region $REGION \
  --cluster-arn "$CLUSTER_ARN" \
  --current-version "$CURRENT_VERSION" \
  --connectivity-info file://connectivity.json
```

3. **Abra o SG do MSK** só para seu IP:
* Já se encontrado liberado 0.0.0.0 no SG, remover depois esta entrada do SG.
* **9098** (privado) **9198**(publico)  (IAM) e/ou **9094** (SCRAM)

4. **Depois do teste**, volte para `DISABLED` (faça o mesmo comando com `"Type":"DISABLED"`).

---

## Teste rápido com Kafka Client

1. **Baixe o Kafka Client**
   👉 [https://kafka.apache.org/downloads](https://kafka.apache.org/downloads) (use 3.6.x/3.7.x/3.9.x)

2. **(IAM) Baixe o JAR de autenticação**
   👉 [https://github.com/aws/aws-msk-iam-auth/releases](https://github.com/aws/aws-msk-iam-auth/releases)

   * Ex.: `aws-msk-iam-auth-2.3.2-all.jar`
   * Coloque em `kafka_.../libs/`

3. **Arquivos de propriedades**

`client-iam.properties`:

```properties
security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
```

`client-scram.properties`:

```properties
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
  username="appclient" password="<SENHA_DO_SECRET>";
```

4. **Endpoints**

```bash
aws kafka get-bootstrap-brokers --cluster-arn "$CLUSTER_ARN" --region $REGION
# use BootstrapBrokerStringSaslIam (9098) ou BootstrapBrokerStringSaslScram (9094)
```

5. **Criar tópico / Produzir / Consumir (IAM)**

```bash
BOOTSTRAP="<BootstrapBrokerStringSaslIam>"

bin/kafka-topics.sh --bootstrap-server "$BOOTSTRAP" \
  --command-config client-iam.properties \
  --create --topic demo.topic --partitions 3 --replication-factor 2

bin/kafka-console-producer.sh --bootstrap-server "$BOOTSTRAP" \
  --producer.config client-iam.properties \
  --topic demo.topic

bin/kafka-console-consumer.sh --bootstrap-server "$BOOTSTRAP" \
  --consumer.config client-iam.properties \
  --topic demo.topic --from-beginning
```

*(Para SCRAM, troque o properties e use o `BootstrapBrokerStringSaslScram`/9094.)*

---

## Segurança

* Restrinja **Security Groups** às origens necessárias (IP/SG).
* Para IAM, aplique **cluster policy** permitindo **apenas** seus principals e, idealmente, por **prefixo de tópico/grupo**.
* Secrets do SCRAM: **KMS CMK** custom (MSK **não aceita** a default key do Secrets Manager).
* Em produção, ajuste os parâmetros da **Configuration** conforme suas necessidades de durabilidade/desempenho.

---

## Destruir

```bash
terraform destroy
```

> Se o cluster estiver com **público habilitado**, volte para `DISABLED` antes de destruir (ou o update pode travar por policy/SG).

---

## Troubleshooting

* **Timeout ao criar tópico do seu PC**: cluster **privado**; use EC2 na VPC ou habilite público temporário.
* **Authorization failed (IAM)**: verifique **cluster policy**, **IAM policy da role**, `authorizer.class.name` e uso do **JAR**.
* **InvalidSecretArn (SCRAM)**: Secret está com a **default key**; recrie com **kms\_key\_id** (CMK simétrica).
* **UpdateConnectivity falhou**: falta `allow.everyone.if.no.acl.found=false` (e IAM authorizer, se for IAM).

---

---

## Referências úteis

* 🎥 **Vídeo**: [https://www.youtube.com/watch?v=gfaVCH\_2v\_Y](https://www.youtube.com/watch?v=gfaVCH_2v_Y)
* 📄 **AWS MSK – Operações**: [https://docs.aws.amazon.com/msk/latest/developerguide/operations.html](https://docs.aws.amazon.com/msk/latest/developerguide/operations.html)
* 📚 **Terraform AWS – MSK Cluster Resource**: [https://registry.terraform.io/providers/hashicorp/aws/6.8.0/docs/resources/msk\_cluster](https://registry.terraform.io/providers/hashicorp/aws/6.8.0/docs/resources/msk_cluster)

---