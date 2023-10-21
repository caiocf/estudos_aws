# Descrição do Código Terraform

Este código Terraform configura recursos relacionados ao Amazon S3 (Simple Storage Service) na Amazon Web Services (AWS).

## Recursos Configurados

O código realiza as seguintes tarefas:

a) Cria um bucket no Amazon S3 com permissões específicas para o Amazon Storage Gateway.

b) Define uma política de acesso que concede permissões no bucket criado e cria uma função (role) que está vinculada a essa política. Além disso, estabelece uma relação de confiança para um usuário existente na AWS.

## Comandos Terraform

- Para aplicar esta configuração e criar os recursos na AWS, execute os seguintes comandos no terminal:

  ```shell
  terraform init
  terraform apply -var-file=inventories/hom/terraform.tfvars
  ```

- Para destruir todos os recursos criados anteriormente e limpar o ambiente, execute o seguinte comando:

  ```shell
  terraform destroy -var-file=inventories/hom/terraform.tfvars
  ```

Certifique-se de substituir `inventories/hom/terraform.tfvars` pelo caminho correto para seu arquivo de variáveis de configuração, se necessário.