# AWS MSK Configuration – Revisão 

Este projeto contém a configuração de **Amazon MSK** (Managed Streaming for Apache Kafka) utilizada na *Revisão* do cluster.

A configuração é aplicada aos brokers do MSK para definir parâmetros padrão de tópicos, replicação, performance e tolerância a falhas.

## Parâmetros da Configuração

| Parâmetro | Valor | Descrição |
|-----------|-------|-----------|
| **auto.create.topics.enable** | `true` | Permite a criação automática de tópicos quando referenciados por um produtor/consumer. **Atenção:** não recomendado em produção para evitar tópicos acidentais. |
| **default.replication.factor** | `2` | Número padrão de réplicas para novos tópicos. Com 2 réplicas é possível tolerar a falha de 1 broker. |
| **log.retention.hours** | `168` | Tempo de retenção padrão de mensagens (em horas). 168h = **7 dias**. Pode ser ajustado por tópico. |
| **min.insync.replicas** | `1` | Mínimo de réplicas no conjunto ISR que precisam confirmar a escrita para `acks=all`. Valores maiores aumentam durabilidade. |
| **num.io.threads** | `8` | Threads dedicadas a operações de I/O (rede/disco). |
| **num.network.threads** | `5` | Threads para lidar com conexões de rede. |
| **num.partitions** | `2` | Número padrão de partições para novos tópicos (quando não especificado). |
| **num.replica.fetchers** | `2` | Threads de replicação por broker para sincronizar dados de líderes. |
| **replica.lag.time.max.ms** | `30000` | Tempo máximo (ms) que uma réplica pode ficar atrás antes de sair do ISR. |
| **socket.receive.buffer.bytes** | `102400` | Tamanho do buffer de recepção do socket (em bytes). |
| **socket.request.max.bytes** | `104857600` | Tamanho máximo de uma requisição ao broker (em bytes). |
| **socket.send.buffer.bytes** | `102400` | Tamanho do buffer de envio do socket (em bytes). |
| **unclean.leader.election.enable** | `true` | Permite eleição de líderes não-sincronizados caso todos os ISR falhem. **Atenção:** pode causar perda de dados. |
| **zookeeper.session.timeout.ms** | `18000` | Timeout da sessão do broker com o Zookeeper (em ms). |

---

## Observações Importantes

- Esta configuração é adequada para **ambientes de desenvolvimento** e **testes**.  
- Para **produção**, recomenda-se:
  - `auto.create.topics.enable = false`
  - `default.replication.factor = 3` (se houver 3 brokers/AZs)
  - `min.insync.replicas = 2` (com RF=3)
  - `unclean.leader.election.enable = false`
  - Ajustar retenção de mensagens por tópico conforme caso de uso
  - Garantir **acks=all** e **idempotent producer**

---

## Aplicação via Terraform

Esta configuração é gerenciada via Terraform usando o recurso [`aws_msk_configuration`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_configuration) e vinculada ao cluster existente através do `aws_msk_cluster`.

Exemplo simplificado:

```hcl
resource "aws_msk_configuration" "example" {
  name              = "msk-config-rev3"
  kafka_versions    = ["3.6.0"]
  server_properties = <<PROPERTIES
auto.create.topics.enable = true
default.replication.factor = 2
log.retention.hours = 168
min.insync.replicas = 1
num.io.threads = 8
num.network.threads = 5
num.partitions = 2
num.replica.fetchers = 2
replica.lag.time.max.ms = 30000
socket.receive.buffer.bytes = 102400
socket.request.max.bytes = 104857600
socket.send.buffer.bytes = 102400
unclean.leader.election.enable = true
zookeeper.session.timeout.ms = 18000
PROPERTIES
}

resource "aws_msk_cluster" "example" {
  # ...
  configuration_info {
    arn      = aws_msk_configuration.example.arn
    revision = aws_msk_configuration.example.latest_revision
  }
}
````

---

## Links Úteis

* [Documentação Oficial do Amazon MSK](https://docs.aws.amazon.com/msk/latest/developerguide/what-is-msk.html)
* [Parâmetros de Configuração do Kafka](https://kafka.apache.org/documentation/#brokerconfigs)
* [Terraform AWS MSK Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_configuration)


