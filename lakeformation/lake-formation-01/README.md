# AWS Lake Formation - Terraform Project

Este projeto provisiona uma infraestrutura simples de Data Lake com S3, Glue, Lake Formation e Athena. O foco aqui e estudo de autorizacao: quem pode consultar a tabela, como o Athena conversa com o catalogo e como o Lake Formation controla o acesso ao dado no S3.

## Recursos criados

### Storage
- **S3 Bucket**: bucket principal do Data Lake
- **S3 Objects**: prefixos `customers/` e `scripts/`
- **Athena Results Bucket**: bucket dedicado para os resultados do workgroup customizado do Athena

### Data Catalog
- **Glue Database**: database definido pela variavel `database_name`
- **Glue Table**: tabela externa `customers`

### Lake Formation
- **Data Lake Location**: registro do bucket S3 no Lake Formation
- **Permissions**: grants minimos para consulta
- **Admins**: reaproveita os admins ja existentes e adiciona o principal atual do provider/AWS CLI

### Analytics
- **Athena Workgroup**: workgroup customizado gerenciado pelo Terraform

### Networking
- **VPC Endpoint S3**: gateway endpoint para acesso ao S3
- **VPC Endpoint Glue**: interface endpoint para acesso ao Glue

### IAM
- **IAM User**: usuario `aws-user` com permissao minima para consultar via Athena
- **IAM User**: usuario `aws-user-2` com filtro de linhas e colunas no Lake Formation
- **IAM User**: usuario `aws-user-3` com `SELECT` em todas as tabelas do database
- **IAM Role**: role dedicada usada pelo Lake Formation para acessar os dados no S3

## Pre-requisitos

- Terraform >= 1.0
- Credenciais AWS com permissoes adequadas
- Use um user ou role com permissao administrativa no Lake Formation para registrar a data location, criar database e tabela e aplicar os grants do laboratorio

## Variaveis

| Nome | Descricao | Padrao |
|------|-----------|--------|
| aws_region | Regiao AWS | us-east-1 |
| bucket_name | Nome do bucket S3 | meu-glue-lake-02 |
| athena_results_bucket_name | Nome do bucket S3 dedicado aos resultados do Athena | meu-athena-workgroup-results-02 |
| database_name | Nome do database Glue | meu-database |
| iam_user_name | Nome do usuario IAM | aws-user |
| iam_user_2_name | Nome do segundo usuario IAM | aws-user-2 |
| iam_user_3_name | Nome do terceiro usuario IAM | aws-user-3 |
| workgroup_name | Nome do Athena workgroup | meu-workgroup |

## Como usar

### 1. Inicializar o Terraform

```bash
terraform init
```

### 2. Planejar as mudancas

```bash
terraform plan
```

### 3. Aplicar a infraestrutura

```bash
terraform apply
```

### 4. Consultar dados via Athena

Exemplo para o `aws-user`:

```sql
SELECT *
FROM "meu-database"."customers";
```

Exemplo para o `aws-user-2`:

```sql
SELECT *
FROM "meu-database"."customers";
```

Exemplo para o `aws-user-3`:

```sql
SELECT *
FROM "meu-database"."customers";
```

## Estrutura de arquivos

```text
.
|-- athena.tf           # Bucket de resultados e workgroup do Athena
|-- data.tf             # Data sources (VPC, subnets, etc)
|-- glue.tf             # Database e tabela no Glue Catalog
|-- iam.tf              # IAM user, role e policy minima do usuario
|-- lakeformation.tf    # Data lake settings e data location
|-- main.tf             # Bucket S3 e objetos iniciais
|-- outputs.tf          # Outputs importantes
|-- permissions.tf      # Grants do Lake Formation
|-- provider.tf         # Provider AWS
|-- variables.tf        # Variaveis do projeto
|-- vpc_endpoints.tf    # VPC Endpoints
`-- customers.csv       # Dados de exemplo
```

## Permissoes do usuario `aws-user`

O objetivo deste projeto e mostrar o conjunto minimo de permissoes para um usuario consultar a tabela `customers` no Athena com governanca feita pelo Lake Formation.

### 1. Permissoes no Lake Formation

O `aws-user` recebe os seguintes grants:

- `SELECT` somente nas colunas `customer_name` e `region` da tabela `customers`

Isso permite consulta de leitura sem permitir alterar metadados ou escrever dados. No Athena, `SELECT *` tende a retornar apenas `customer_name` e `region`, porque o servico respeita a filtragem de colunas do Lake Formation. Ja consultas que referenciem `customer_id` ou `email` explicitamente devem falhar por falta de permissao.

### 2. Permissoes IAM do `aws-user`

O `aws-user` recebe uma policy IAM inline minima com:

- `lakeformation:GetDataAccess`
- acoes do Athena para listar catalogo/workgroups e executar queries
- leitura do status e do resultado das queries
- acesso S3 apenas ao bucket de resultados no prefixo do workgroup

Na pratica, isso significa:

- o usuario pode abrir o Athena e rodar `SELECT`
- o usuario pode ler os resultados da query
- o usuario nao recebe acesso amplo ao bucket S3

### 3. O que o usuario nao recebe

O `aws-user` nao recebe:

- `ALTER`, `DROP`, `DELETE`, `INSERT` ou `ALL` na tabela
- permissao administrativa no Lake Formation
- acesso direto ao prefixo `customers/` no S3
- senha de console ou access key criadas automaticamente

Esse ultimo ponto e importante: o Terraform cria o usuario IAM, mas nao cria credenciais de uso. Se voce quiser entrar no console ou usar CLI como `aws-user`, precisa criar login profile ou access key separadamente.

### 4. Como a autorizacao funciona

Fluxo simplificado de uma consulta:

1. O `aws-user` inicia a query no Athena workgroup configurado.
2. O Athena consulta o Glue Catalog e o Lake Formation.
3. O Lake Formation valida se o usuario tem `SELECT` nas colunas permitidas.
4. O Lake Formation usa a role dedicada para ler o dado em `customers/`.
5. O Athena grava o resultado da query em `s3://<athena-results-bucket>/<workgroup-name>/`.

Esse desenho e util para estudo porque separa claramente:

- autorizacao no catalogo
- execucao da query
- acesso fisico ao dado no S3

### 5. IAM x Lake Formation

Neste projeto, o usuario consegue listar databases e tabelas no Athena por causa das permissoes IAM de leitura no Glue Data Catalog.

Ja o acesso real aos dados e controlado pelo Lake Formation:

- o `aws-user` so pode consultar as colunas `customer_name` e `region`
- o `aws-user-2` so pode consultar `email` e `region`
- o `aws-user-2` so pode ver linhas em que `region = 'NA'`
- o `aws-user-3` pode consultar todas as colunas das tabelas do database

Por isso, listar objetos no console e conseguir ler o conteudo das colunas/linhas sao coisas diferentes neste laboratorio.

## Permissoes do usuario `aws-user-2`

O `aws-user-2` recebe a mesma policy IAM do `aws-user` para usar Athena, Glue, Lake Formation e o bucket de resultados do workgroup.

No Lake Formation, ele recebe:

- `SELECT` por meio de um data cells filter

O data cells filter limita o acesso a:

- linhas onde `region = 'NA'`
- colunas `email` e `region`

Para esse usuario, uma consulta valida seria:

```sql
SELECT *
FROM "meu-database"."customers";
```

No Athena, `SELECT *` tende a retornar apenas as colunas `email` e `region`, e somente linhas em que `region = 'NA'`. Consultas que referenciem `customer_name` ou `customer_id` explicitamente devem falhar por falta de permissao.

## Permissoes do usuario `aws-user-3`

O `aws-user-3` recebe a mesma policy IAM do `aws-user` para usar Athena, Glue, Lake Formation e o bucket de resultados do workgroup.

No Lake Formation, ele recebe:

- `SELECT` em todas as tabelas do database `meu-database`

Neste laboratorio, como o database hoje tem a tabela `customers`, ele consegue consultar todas as colunas dessa tabela. Se novas tabelas forem criadas no mesmo database, o grant com `wildcard = true` cobre essas tabelas tambem.

Uma consulta valida para esse usuario seria:

```sql
SELECT *
FROM "meu-database"."customers";
```

## Observacoes

- Neste projeto, `SELECT *` continua sendo util para teste porque o Athena expande apenas as colunas visiveis para o principal no Lake Formation.
- O Athena console pode continuar listando databases e tabelas mesmo sem grants `DESCRIBE` em database, porque isso hoje vem das permissoes IAM do Glue.
- Se voce quiser validar o bloqueio de colunas, faca queries referenciando explicitamente colunas fora do grant, como `customer_id`, `customer_name` ou `email`, dependendo do usuario testado.

## Limpeza

Para destruir todos os recursos:

```bash
terraform destroy
```

Nota: o projeto usa uma IAM role dedicada em vez da service-linked role para evitar problemas na destruicao dos recursos do Lake Formation.

## Boas praticas implementadas

- Uso de variaveis para valores configuraveis
- Tags em todos os recursos
- Comentarios explicativos no Terraform
- Outputs para informacoes importantes
- Separacao logica de recursos em arquivos
- Modo Lake Formation only para estudo de governanca
- Permissoes minimas para consulta no Athena

## Troubleshooting

### Erro: insufficient Lake Formation permissions

Verifique se o principal que executa o Terraform e um user ou role com permissao administrativa no Lake Formation para registrar a data location, criar database e tabela e aplicar grants.

### Erro: acesso negado no Athena para o `aws-user`

Revise estes pontos:

- `terraform apply` foi executado depois da criacao da policy IAM e dos grants
- o `aws-user` possui alguma credencial de acesso para console ou CLI
- a consulta esta usando o workgroup criado pelo Terraform
- o bucket de resultados continua apontando para o prefixo do workgroup

### Erro: bucket not empty

Os buckets usam `force_destroy = true`, mas se houver problemas, esvazie manualmente:

```bash
aws s3 rm s3://meu-glue-lake-02 --recursive
aws s3 rm s3://meu-athena-workgroup-results-02 --recursive
```
