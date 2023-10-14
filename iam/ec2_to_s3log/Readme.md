Claro, aqui está uma atualização do Markdown que inclui os comandos `plan` e `destroy` para cada ambiente:

# Projeto de Infraestrutura na AWS

## Descrição do Projeto

Este projeto tem como objetivo criar uma infraestrutura na Amazon Web Services (AWS) que permitirá a implantação de instâncias EC2 com permissões específicas. A infraestrutura inclui a definição de uma política personalizada, uma função IAM e a vinculação dessa política à função. Essas configurações fornecem um ambiente seguro para que instâncias EC2 enviem logs para o CloudWatch Logs, acessem um bucket S3 específico e recuperem segredos do AWS Secrets Manager.

## Utilidade do Projeto

A utilidade deste projeto reside na criação de uma infraestrutura segura e altamente controlada que permite que instâncias EC2 executem ações específicas com permissões bem definidas. Ele é útil em cenários em que você precisa de um ambiente em que as instâncias EC2 possam:

- Enviar logs para o CloudWatch Logs para monitoramento e auditoria.
- Acessar um bucket S3 para armazenamento de dados.
- Recuperar segredos do AWS Secrets Manager para autenticação e configuração segura.

Este projeto pode ser adaptado e expandido para atender às necessidades específicas de implantação da sua aplicação na AWS.

## Ambientes de Desenvolvimento

Este projeto suporta dois ambientes: desenvolvimento (dev) e homologação (hom). Cada ambiente possui suas próprias configurações, como variáveis específicas.

### Variáveis de Ambiente

- **Dev:** As variáveis de ambiente para o ambiente de desenvolvimento podem ser encontradas em `inventories/dev/terraform.tfvars`. Elas incluem configurações específicas para o ambiente de desenvolvimento, como nomes de recursos exclusivos ou configurações de região.

- **Hom:** As variáveis de ambiente para o ambiente de homologação podem ser encontradas em `inventories/hom/terraform.tfvars`. Elas incluem configurações específicas para o ambiente de homologação, que podem ser diferentes das configurações de desenvolvimento.

## Comandos do Terraform

Aqui estão os comandos do Terraform para criar, planejar e destruir a infraestrutura nos ambientes de desenvolvimento e homologação:

### Ambiente de Desenvolvimento (Dev)

Para implantar a infraestrutura no ambiente de desenvolvimento, execute o seguinte comando:

```shell
terraform apply -var-file=inventories/dev/terraform.tfvars
```

Isso aplicará as configurações específicas do ambiente de desenvolvimento definidas em `inventories/dev/terraform.tfvars`.

Para visualizar as mudanças planejadas antes de aplicá-las, execute:

```shell
terraform plan -var-file=inventories/dev/terraform.tfvars
```

Para destruir a infraestrutura no ambiente de desenvolvimento, execute:

```shell
terraform destroy -var-file=inventories/dev/terraform.tfvars
```

### Ambiente de Homologação (Hom)

Para implantar a infraestrutura no ambiente de homologação, execute o seguinte comando:

```shell
terraform apply -var-file=inventories/hom/terraform.tfvars
```

Isso aplicará as configurações específicas do ambiente de homologação definidas em `inventories/hom/terraform.tfvars`.

Para visualizar as mudanças planejadas antes de aplicá-las, execute:

```shell
terraform plan -var-file=inventories/hom/terraform.tfvars
```

Para destruir a infraestrutura no ambiente de homologação, execute:

```shell
terraform destroy -var-file=inventories/hom/terraform.tfvars
```

Lembre-se de que você pode personalizar as variáveis em cada arquivo `terraform.tfvars` de acordo com as necessidades específicas de cada ambiente. Certifique-se de ajustar as configurações conforme necessário para o ambiente em que você está implantando a infraestrutura.