# Descrição do Código Terraform

Este código Terraform configura recursos no Amazon Web Services (AWS) relacionados ao Amazon S3 (Simple Storage Service).

## Recursos Configurados

### Provider AWS
- Define a região da AWS a ser usada com base na variável `aws_region`.

### Data Source `aws_canonical_user_id`
- Obtém o ID canônico do usuário atual da AWS. Este ID é usado posteriormente nas configurações de controle de acesso.

### Resource `aws_s3_bucket`
- Cria um novo bucket no Amazon S3 com o nome especificado na variável `name_bucket`.
- Define tags no bucket para identificação.

### Resource `aws_s3_bucket_versioning`
- Habilita o controle de versão para o bucket criado. Isso permite que várias versões de objetos sejam armazenadas e recuperadas no bucket.

### Resource `aws_s3_object`
- Cria um objeto no bucket com a chave (key) "meuArquivo.txt". O objeto é copiado de um arquivo chamado "meuArquivo.txt" no local onde o código Terraform é executado.

### Resource `aws_s3_bucket_public_access_block`
- Configura o bloqueio de acesso público no bucket, impedindo que ACLs públicas e políticas públicas sejam aplicadas.

### Resource `aws_s3_bucket_ownership_controls`
- Configura as regras de controle de propriedade do bucket para garantir que os objetos carregados no bucket tenham propriedade preferencial do proprietário do bucket.

### Resource `aws_s3_bucket_acl`
- Define políticas de controle de acesso (ACL) no bucket.
- Concede permissão de leitura (READ) para o usuário atual da AWS usando o ID canônico.
- Concede permissão de leitura de ACLs (READ_ACP) para o grupo "LogDelivery" para permitir o registro de acesso a objetos.

## Casos de Uso

- Este código é útil quando você precisa automatizar a criação de um bucket no Amazon S3, habilitar o controle de versão e definir políticas de controle de acesso para objetos no bucket.
- Também é útil para controlar o acesso público ao bucket e garantir que o proprietário do bucket tenha preferência na propriedade de objetos.

## Comandos Terraform

- Para aplicar a configuração e criar os recursos na AWS, execute:
  ```
    terraform init
    terraform apply -var-file=inventories/hom/terraform.tfvars
  ```

- Para destruir todos os recursos criados anteriormente, execute:
  ```
    terraform destroy -var-file=inventories/hom/terraform.tfvars
  ```

Certifique-se de que as variáveis, como `aws_region` e `bucket_name` e `bucket_versioning`, estejam definidas corretamente antes de executar os comandos Terraform.

