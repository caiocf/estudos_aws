# AWS Lake Formation - Terraform Project

Este projeto provisiona uma infraestrutura completa de Data Lake usando AWS Lake Formation, Glue, S3 e Athena.

## Recursos Criados

### Storage
- **S3 Bucket**: Bucket para armazenamento de dados do Data Lake
- **S3 Objects**: Pastas para customers, athena results e scripts

### Data Catalog
- **Glue Database**: Database para organização de metadados
- **Glue Table**: Tabela customers com schema definido

### Lake Formation
- **Data Lake Location**: Registro do bucket S3 como Data Lake
- **Permissions**: Permissões granulares para usuários
- **Admins**: Configuração de administradores do Data Lake

### Analytics
- **Athena Workgroup**: Workgroup para execução de queries

### Networking
- **VPC Endpoint S3**: Gateway endpoint para acesso ao S3
- **VPC Endpoint Glue**: Interface endpoint para acesso ao Glue

### IAM
- **IAM User**: Usuário para consultas no Lake Formation
- **IAM Role**: Role dedicada para acesso aos dados do Lake Formation

## Pré-requisitos

- Terraform >= 1.0
- AWS CLI configurado
- Credenciais AWS com permissões adequadas
- Usuário IAM existente especificado na variável `existing_admin_user`

## Variáveis

| Nome | Descrição | Padrão |
|------|-----------|--------|
| aws_region | Região AWS | us-east-1 |
| bucket_name | Nome do bucket S3 | meu-glue-lake-02 |
| database_name | Nome do database Glue | meu-database |
| iam_user_name | Nome do usuário IAM | aws-user |
| existing_admin_user | Usuário admin existente | usuario |
| workgroup_name | Nome do Athena workgroup | meu-workgroup |

## Como Usar

### 1. Inicializar o Terraform

```bash
terraform init
```

### 2. Planejar as mudanças

```bash
terraform plan
```

### 3. Aplicar a infraestrutura

```bash
terraform apply
```

### 4. Consultar dados via Athena

```sql
SELECT * FROM "meu-database"."customers" LIMIT 10;
```

## Estrutura de Arquivos

```
.
├── athena.tf           # Configuração do Athena
├── data.tf             # Data sources (VPC, subnets, etc)
├── glue.tf             # Database e tabelas do Glue
├── iam.tf              # Usuários IAM
├── lakeformation.tf    # Configurações do Lake Formation
├── main.tf             # Bucket S3 e objetos
├── outputs.tf          # Outputs do Terraform
├── permissions.tf      # Permissões do Lake Formation
├── provider.tf         # Configuração do provider AWS
├── variables.tf        # Variáveis do projeto
├── vpc_endpoints.tf    # VPC Endpoints
└── customers.csv       # Dados de exemplo
```

## Permissões Lake Formation

O projeto configura dois tipos de permissões:

1. **Database permissions**: Para gerenciamento (CREATE_TABLE, DROP, etc)
2. **Table permissions**: Para consultas (SELECT, INSERT, etc)

## Limpeza

Para destruir todos os recursos:

```bash
terraform destroy
```

**Nota**: O projeto usa uma IAM role dedicada em vez da service-linked role para evitar problemas na destruição dos recursos.

## Boas Práticas Implementadas

- ✅ Uso de variáveis para valores configuráveis
- ✅ Tags em todos os recursos
- ✅ Comentários explicativos
- ✅ Outputs para informações importantes
- ✅ Separação lógica de recursos em arquivos
- ✅ Lake Formation only mode (segurança)
- ✅ Force destroy habilitado para facilitar testes
- ✅ Documentação completa

## Troubleshooting

### Erro: Usuário admin não encontrado

Certifique-se de que o usuário especificado na variável `existing_admin_user` existe no IAM.

### Erro: Insufficient Lake Formation permissions

Certifique-se de que o usuário executando o Terraform tem permissões de admin no Lake Formation.

### Erro: Bucket not empty

O bucket tem `force_destroy = true`, mas se houver problemas, esvazie manualmente:

```bash
aws s3 rm s3://meu-glue-lake-02 --recursive
```
