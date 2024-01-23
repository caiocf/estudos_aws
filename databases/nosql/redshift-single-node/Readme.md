Aqui está uma versão melhorada do seu Markdown para descrever o projeto Terraform:

---

## Projeto Terraform: AWS Redshift e Infraestrutura Relacionada

Este projeto utiliza Terraform para criar os seguintes recursos na AWS:

- **AWS Redshift Cluster**: Configurado com criptografia em trânsito e em repouso, utilizando um servidor provisionado, single-node e node type de dc2.large, 
- **AWS Secrets Manager**: Gerencia a senha do Redshift de forma segura.
- **VPC Privada**: Criada através de um módulo Terraform para isolar o ambiente de rede.
- **AWS KMS (Key Management Service)**: Utilizado para gerenciar a criptografia dos dados.
- **Bucket S3**: Armazena os logs do cluster Redshift.
- **Grupo de Parâmetros do Redshift**: Configura limites para querys concorrentes, SSL e sensibilidade a maiúsculas e minúsculas (case-sensitive).

### Criação dos Recursos

Para criar os recursos com Terraform, execute o seguinte comando no terminal:

```shell
terraform apply
```

#### Outputs do Terraform:

- **Endpoint do Cluster Redshift**:
  ```
  redshift_cluster_endpoint = "redshift-vendasdb-app.c5ee3abzalbu.us-east-1.redshift.amazonaws.com:5439"
  ```
- **Usuário do Cluster Redshift**:
  ```
  redshift_cluster_username = "user_redshift"
  ```
- **ARN do AWS Secrets Manager**:
  ```
  secrets_manager_arn = "arn:aws:secretsmanager:us-east-1:202397874162:secret:redshift!redshift-vendasdb-app-user_redshift-t0VUsf"
  ```

Após a criação dos recursos, você pode se conectar ao cluster Redshift usando a AWS Query Editor ou outras ferramentas de cliente compatíveis.

### Destruição dos Recursos

Para remover todos os recursos criados por este projeto Terraform, execute:

```shell
terraform destroy
```

---

Este formato melhora a legibilidade e a organização das informações, tornando mais claro quais recursos estão sendo criados e como interagir com eles.