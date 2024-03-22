# Projeto de Criação de Filas SQS

Este projeto cria duas filas no AWS SQS:

1. **Fila Padrão:** Configurada para tratamento e entrega de mensagens de forma eficiente. Mensagens não processadas após 5 tentativas serão enviadas para a DLQ.
2. **Fila DLQ (Dead Letter Queue):** Destinada a receber mensagens não processadas da fila padrão.

Além disso, o projeto configura duas IAM roles:
- Uma role com permissão para escrever na fila.
- Outra role com permissão para ler da fila, destinada a funções Lambda.

## Configurações da Fila Padrão

As configurações definidas para a fila padrão são:

- **Tempo de Atraso:** 10 segundos. Tempo de atraso para a entrega de todas as mensagens adicionadas à fila.
- **Tamanho Máximo da Mensagem:** 262144 bytes (256 KB). O limite de tamanho para uma mensagem antes de ser enviada para a fila.
- **Tempo de Retenção da Mensagem:** 345600 segundos (4 dias). O período que a SQS reterá uma mensagem caso ela não seja deletada.
- **Tempo de Espera para Recebimento:** 10 segundos. O tempo de espera para a operação `ReceiveMessage` retornar uma mensagem.
- **Timeout de Visibilidade:** 30 segundos. O tempo durante o qual a mensagem será invisível após ser recebida.
- **Política de Redirecionamento para DLQ:** Configuração que especifica que a mensagem será movida para a DLQ após ser recebida 5 vezes sem sucesso.

## Como Executar

Execute os seguintes comandos no terminal para criar as filas e as roles:

```shell
terraform init
terraform apply
```

Após a execução, você verá uma saída similar a:

```
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

arn_sqs_dlq = "https://sqs.us-east-1.amazonaws.com/975049978641/minha-fila-dlq"
arn_sqs_padrao = "https://sqs.us-east-1.amazonaws.com/975049978641/minha-fila-padrao"
```

## Publicar e Receber Mensagens (Teste)

### Publicar uma Mensagem

Para publicar uma mensagem na fila padrão via AWS CLI:

```shell
aws sqs send-message --queue-url https://sqs.us-east-1.amazonaws.com/975049978641/minha-fila-padrao --message-body "Mensagem de teste ABC"
```

### Receber Mensagem

Para receber mensagens (com tempo de espera definido na criação via Terraform):

```shell
aws sqs receive-message --queue-url https://sqs.us-east-1.amazonaws.com/975049978641/minha-fila-padrao
```

Note que receber a mensagem não a remove da fila. Para remover, você deve deletar a mensagem após o processamento.

### Deletar Mensagem

Utilize o `ReceiptHandle` da mensagem recebida para deletá-la:

```shell
aws sqs delete-message --queue-url https://sqs.us-east-1.amazonaws.com/975049978641/minha-fila-padrao --receipt-handle RECEIPT_HANDLE
```

Substitua `RECEIPT_HANDLE` pelo identificador recebido ao receber a mensagem.
