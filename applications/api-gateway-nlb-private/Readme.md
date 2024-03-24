# Criação de API Gateway REST com Terraform

Este projeto cria uma API Gateway do tipo REST no AWS e a conecta a um NLB (Network Load Balancer) de tipo interno (dentro de uma subnet privada), além de criar um VPC Link.

## Recursos Criados

- **Utiliza o módulo `ec2-nlb`**:
    - Cria uma instância EC2 que hospeda uma aplicação PetStore.
    - Cria um Target Group e um NLB do tipo interno exposto na porta 80.
- **Cria um VPC Link** utilizando o ARN do NLB.
- **Cria uma API Gateway do tipo REST** usando o contrato OpenAPI do PetStore.
    - Utiliza o modelo `template_file` para passar as variáveis de URL do NLB e o ID do VPC Link para o `x-amazon-apigateway-integration`.
    - Cria um stage parametrizado chamado "dev".
    - Cria uma role para que a API Gateway possa escrever no CloudWatch e um grupo no CloudWatch.

### Observação

Todos os recursos usam a VPC default da conta.

## Pré-Requisitos

- Terraform v0.12 ou superior.
- Acesso configurado à AWS CLI e Terraform com permissões adequadas.

## Como Executar

### 1. Inicialização do Terraform

Para preparar o Terraform para execução, utilize:

```bash
terraform init
```

### 2. Planejamento do Terraform

Para revisar as mudanças propostas antes da aplicação, execute:

```bash
terraform plan
```

### 3. Aplicação das Alterações

Para criar a infraestrutura especificada, execute:

```bash
terraform apply
```

## Limpeza dos Recursos

Quando os recursos não forem mais necessários, utilize o comando abaixo para evitar custos desnecessários:

```bash
terraform destroy
```
