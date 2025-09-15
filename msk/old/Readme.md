# conenctar ao postgre e cria os recurso abaixo

Este projeto consiste na criação de solução do Patterner OutBox.
Recursos Criados:
- Aurora PostgreSQL 16 (1 Writer e 1 Reader)
  - Habilitado o rds.logical_replication para leitura do Plugin Debezium
- Msk 3.6.0 Provisionado
- Msk Connect
  - Instalação do Plugin do Debezium para Postgres
  - Configuração Worker para Suporte Secret e S3Import (não utlizado)
  - Conector com Debezium no RDS Auorora lendo a tabela outpbox e publicando topico do MSK
- Criação maquinas EC2
  - Com Instance Profile (Role) para Conectar no MSK 
  - Instalado cliente Msk e configurado para com autenticação IAM no usuario ec2-user
  - Instalado cliente pgsql client para o Postgree. 


Primeira passo criar os recurso:
```shell
terraform init
terraform apply
```

Faça o acompanhamento da criação dos recursos na console web, assim que completa a criação do RDS realiza a conexão e crie os recursos abaixo:
1 - Cria a tabela chamada public.outbox

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.outbox (
id             uuid PRIMARY KEY,
aggregate_type text      NOT NULL,  -- ex: 'orders'
aggregate_id   text      NOT NULL,  -- ex: 'order-123'
type           text      NOT NULL,  -- ex: 'OrderCreated'
payload        jsonb     NOT NULL,  -- corpo do evento
timestamp      timestamptz NOT NULL DEFAULT now(),
trace_id       text,
tenant_id      text
);

-- Índices úteis
-- CREATE INDEX IF NOT EXISTS idx_outbox_aggtype ON public.outbox (aggregatetype);
-- CREATE INDEX IF NOT EXISTS idx_outbox_aggid   ON public.outbox (aggregateid);


INSERT INTO public.outbox (id, aggregate_type, aggregate_id, type, payload)
VALUES (gen_random_uuid(), 'orders', 'order-123', 'OrderCreated',
'{"id": "order-123", "total": 99.90, "items": [{"sku":"X","qty":1}]}'::jsonb);

INSERT INTO public.outbox (id, aggregate_type, aggregate_id, type, payload, trace_id, tenant_id)
VALUES (gen_random_uuid(), 'orders', 'order-123', 'OrderCreated',
'{"id":"order-123","total":99.90}'::jsonb, 'abc-123', 'tenant-01');


CREATE PUBLICATION debezium_pub FOR TABLE public.outbox;


# ouvir evento publicado.

kafka-console-consumer.sh \
--bootstrap-server "$BOOTSTRAP" \
--consumer.config "$KAFKA_HOME/config/client-iam.properties" \
--topic outbox.event.orders --from-beginning



https://www.youtube.com/watch?v=G87fm-tjhmY
https://github.com/JayaprakashKV/streaming-pipeline-aws


https://repost.aws/questions/QUHDBV6n40SeyevDIiopfdoA/mks-service-with-debezium
https://aws.amazon.com/pt/blogs/aws/introducing-amazon-msk-connect-stream-data-to-and-from-your-apache-kafka-clusters-using-managed-connectors/
https://docs.aws.amazon.com/pt_br/msk/latest/developerguide/msk-connect-debeziumsource-connector-example-steps.html
https://debezium.io/documentation/reference/stable/transformations/outbox-event-router.html
https://www.youtube.com/watch?v=QJFqfbVcD6s
https://repost.aws/questions/QUHDBV6n40SeyevDIiopfdoA/mks-service-with-debezium
https://medium.com/data-hackers/integra%C3%A7%C3%A3o-de-dados-em-tempo-real-do-postgres-para-o-s3-com-debezium-65b0ac97bdb2

connector.class=io.debezium.connector.postgresql.PostgresConnector
tasks.max=1
database.history.consumer.sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
database.history.consumer.sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
database.history.consumer.security.protocol=SASL_SSL



database.history.producer.sasl.mechanism=AWS_MSK_IAM
database.history.producer.sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
database.history.producer.sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
database.history.producer.security.protocol=SASL_SSL

database.history.sasl.mechanism=AWS_MSK_IAM
database.history.sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
database.history.sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
database.history.security.protocol=SASL_SSL
database.history.consumer.sasl.mechanism=AWS_MSK_IAM

database.encrypt=false
database.port=5432
database.names=appdb
database.dbname=appdb
database.hostname=aurora-pg16-slsv2-demo.cluster-cn8dri6vcjdd.us-east-1.rds.amazonaws.com
database.user=adminuser
database.password=2xPI8*IX*:$m0!:Olz1ZVWTlp>L9
table.include.list=public.outbox
schema.include.list=public


value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter=org.apache.kafka.connect.storage.StringConverter

topic.prefix=CDC_DEMO
database.server.name=CDC_DEMO
topic.creation.default.partitions=1
topic.creation.default.replication.factor=3
topic.creation.default.max.message.bytes=20971520
topic.creation.default.retention.ms=2592000000
topic.creation.default.compression.type=snappy
topic.creation.default.cleanup.policy=delete


schema.history.internal.kafka.topic=schemahistory.DEMO_APP

schema.history.internal.kafka.bootstrap.servers=b-1.outboxcdcmskmsk.mytnvk.c9.kafka.us-east-1.amazonaws.com:9098
schema.history.internal.consumer.sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
schema.history.internal.consumer.sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
schema.history.internal.consumer.security.protocol=SASL_SSL
schema.history.internal.consumer.sasl.mechanism=AWS_MSK_IAM
schema.history.internal.producer.sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
schema.history.internal.producer.sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
schema.history.internal.producer.security.protocol=SASL_SSL
schema.history.internal.producer.sasl.mechanism=AWS_MSK_IAM

---------------------------------------------------------------

{
"name": "debezium-aurora-pg-outbox",
"connector.class": "io.debezium.connector.postgresql.PostgresConnector",
"tasks.max": "1",

"database.hostname": "aurora-pg16-slsv2-demo.cluster-cn8dri6vcjdd.us-east-1.rds.amazonaws.com",
"database.port": "5432",
"database.user": "${secretsManager:dbz/aurora/user}",
"database.password": "${secretsManager:dbz/aurora/password}",
"database.dbname": "appdb",
"database.sslmode": "require",

"plugin.name": "pgoutput",
"slot.name": "debezium_slot",
"publication.name": "debezium_pub",
"publication.autocreate.mode": "filtered",
"slot.drop.on.stop": "false",

"topic.prefix": "CDC_DEMO",
"schema.include.list": "public",
"table.include.list": "public.outbox",

"snapshot.mode": "initial",
"tombstones.on.delete": "false",
"provide.transaction.metadata": "true",
"heartbeat.interval.ms": "10000",
"heartbeat.topics.prefix": "__debezium-heartbeat",

"key.converter": "org.apache.kafka.connect.storage.StringConverter",
"value.converter": "org.apache.kafka.connect.json.JsonConverter",
"value.converter.schemas.enable": "false",

"errors.tolerance": "all",
"errors.log.enable": "true",
"errors.deadletterqueue.topic.name": "_dlq.debezium.aurora.pg",
"errors.deadletterqueue.context.headers.enable": "true",

/* ===== Outbox Event Router (remova este bloco se não usar outbox) ===== */
"transforms": "outbox",
"transforms.outbox.type": "io.debezium.transforms.outbox.EventRouter",
"transforms.outbox.table.expand.json.payload": "true",
"transforms.outbox.route.by.field": "aggregate_type",
"transforms.outbox.table.fields.additional.placement": "trace_id:header,tenant_id:header",

/* ====== Kafka AUTH para tópicos de DADOS (Producer/Consumer) ====== */
"producer.security.protocol": "SASL_SSL",
"producer.sasl.mechanism": "AWS_MSK_IAM",
"producer.sasl.jaas.config": "software.amazon.msk.auth.iam.IAMLoginModule required;",
"producer.sasl.client.callback.handler.class": "software.amazon.msk.auth.iam.IAMClientCallbackHandler",

"consumer.security.protocol": "SASL_SSL",
"consumer.sasl.mechanism": "AWS_MSK_IAM",
"consumer.sasl.jaas.config": "software.amazon.msk.auth.iam.IAMLoginModule required;",
"consumer.sasl.client.callback.handler.class": "software.amazon.msk.auth.iam.IAMClientCallbackHandler",

/* ====== Kafka AUTH para o tópico de HISTORY ====== */
"schema.history.internal.kafka.topic": "schemahistory.DEMO_APP",
"schema.history.internal.kafka.bootstrap.servers": "b-1.outboxcdcmskmsk.mytnvk.c9.kafka.us-east-1.amazonaws.com:9098,b-2.outboxcdcmskmsk.mytnvk.c9.kafka.us-east-1.amazonaws.com:9098",
"schema.history.internal.producer.security.protocol": "SASL_SSL",
"schema.history.internal.producer.sasl.mechanism": "AWS_MSK_IAM",
"schema.history.internal.producer.sasl.jaas.config": "software.amazon.msk.auth.iam.IAMLoginModule required;",
"schema.history.internal.producer.sasl.client.callback.handler.class": "software.amazon.msk.auth.iam.IAMClientCallbackHandler",
"schema.history.internal.consumer.security.protocol": "SASL_SSL",
"schema.history.internal.consumer.sasl.mechanism": "AWS_MSK_IAM",
"schema.history.internal.consumer.sasl.jaas.config": "software.amazon.msk.auth.iam.IAMLoginModule required;",
"schema.history.internal.consumer.sasl.client.callback.handler.class": "software.amazon.msk.auth.iam.IAMClientCallbackHandler"
}



select * from information_schema.tables;
# Pressione executar e veja as tabelas de banco de dados atual abaixo

CREATE TABLE IF NOT EXISTS public.outbox (
id UUID PRIMARY KEY,
aggregate_type TEXT NOT NULL,
aggregate_id   TEXT NOT NULL,
type           TEXT,
payload        JSONB NOT NULL,
created_at     TIMESTAMPTZ DEFAULT now()
);

CREATE PUBLICATION debezium_pub FOR TABLE public.outbox;


SHOW rds.logical_replication;  -- on
SHOW wal_level;                -- logical
