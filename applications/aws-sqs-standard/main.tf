# Criando a Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "terraform_queue_deadletter" {
  name = var.nome_fila_dlq

  message_retention_seconds = 1209600 # Tempo de retenção da mensagem (em segundos) - 14 dias

  provider = aws.primary
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.terraform_queue_deadletter.id

  provider = aws.primary

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.my_queue.arn]
  })
}

# Criando a fila SQS padrão com DLQ configurado e outras configurações explícitas
resource "aws_sqs_queue" "my_queue" {
  name                      = var.nome_fila_padrao
  delay_seconds             = 10  # Tempo de atraso para entrega da mensagem (em segundos)
  max_message_size          = 262144 # Tamanho máximo da mensagem (em bytes)
  message_retention_seconds = 345600 # Tempo de retenção da mensagem (em segundos) - 4 dias
  receive_wait_time_seconds = 10  # Tempo de espera longo para recebimento da mensagem (em segundos)
  visibility_timeout_seconds= 30  # Tempo durante o qual a mensagem será invisível após ser recebida (em segundos)

  fifo_queue                = false

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
    maxReceiveCount     = 5 # Número de vezes que a mensagem pode ser recebida antes de ser movida para a DLQ
  })

  provider = aws.primary
}
