# Descrição do Código Terraform

Este código Terraform configura recursos no Amazon Web Services (AWS) relacionados ao Amazon S3 (Simple Storage Service).

Criar bucket para o Cloudfront.

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