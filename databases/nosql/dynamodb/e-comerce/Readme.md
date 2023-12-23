# Projeto Terraform - Criação de Tabela DynamoDB

Este projeto cria uma tabela chamada "user" no DynamoDB com um índice secundário global (GSI) e um índice secundário local (LSI). Também inclui exemplos de consultas.

## Recursos Criados

- Tabela DynamoDB com opções de faturamento (PROVISIONED ou PAY_PER_REQUEST).
- Índice secundário global (GSI) "EmailIndex".
- Índice secundário local (LSI) "LoginDateIndex".
- Itens de exemplo inseridos na tabela.

## Como Usar

Para criar os recursos na AWS:

```shell
terraform init
terraform apply
```

## Exemplos de Consultas

- Consulta pela Chave Primária (UserID = 1).

```shell
aws dynamodb query --table-name user --key-condition-expression "UserID = :uid" --expression-attribute-values '{":uid": {"N": "1"}}'
```
- Consulta pela Chave Primária e Composta (UserID = 1 e OrderID = 101).

```shell
aws dynamodb get-item --table-name user --key "{\"UserID\":{\"N\":\"1\"}, \"OrderID\":{\"N\":\"101\"}}"
```
- Consulta usando o GSI pelo email.
```shell
aws dynamodb query --table-name user --index-name EmailIndex --key-condition-expression "Email = :email" --expression-attribute-values '{":email": {"S": "user1@example.com"}}'
```

- Consulta usando o LSI "LoginDateIndex", ordenando por crescente e decrescente LastLoginDate para UserID = 1.
```shell
aws dynamodb query --table-name user --index-name LoginDateIndex --key-condition-expression "UserID = :uid" --scan-index-forward --expression-attribute-values '{":uid": {"N": "1"}}'
```

```shell
aws dynamodb query --table-name user --index-name LoginDateIndex --key-condition-expression "UserID = :uid" --no-scan-index-forward --expression-attribute-values '{":uid": {"N": "1"}}'
```


Para Excluir os Recursos da AWS:

```shell
terraform destroy
```








