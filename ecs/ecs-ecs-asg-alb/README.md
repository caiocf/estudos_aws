# Terraform - Projeto BIA

## Visão Geral

Este projeto Terraform provisiona a infraestrutura completa para o projeto BIA (Bootcamp de Imersão AWS), seguindo as regras educacionais estabelecidas para simplicidade e aprendizado.

## Arquitetura Criada

### Componentes Principais
- **ECS Cluster** com EC2 instances e Auto Scaling Group
- **Application Load Balancer** para distribuição de tráfego
- **RDS PostgreSQL** (t3.micro) para banco de dados
- **Security Groups** seguindo as regras do projeto BIA
- **IAM Roles** necessárias para ECS
- **ECS Service Auto Scaling** com políticas baseadas em requests

### Recursos Provisionados
```
✅ 19 recursos criados pelo Terraform:
├── ECS (Cluster, Service, Task Definition)
├── ECS Service Auto Scaling (Target + Policy)
├── Auto Scaling Group + Launch Template
├── Application Load Balancer + Target Group + Listener
├── RDS PostgreSQL + Subnet Group
├── 3 Security Groups (ALB, EC2, Database)
└── IAM Roles + Policies + Instance Profile
```

## ECS Service Auto Scaling

### Configuração Implementada
- **Capacidade Mínima:** 2 tasks
- **Capacidade Máxima:** 6 tasks
- **Métrica de Scaling:** ALBRequestCountPerTarget
- **Target Value:** 150 requests por target por minuto
- **Scale Out Cooldown:** 300 segundos (5 minutos)
- **Scale In Cooldown:** 300 segundos (5 minutos)

### Como Funciona
O ECS Service monitora automaticamente o número de requests por target no ALB. Quando a média ultrapassa 150 requests/target/minuto, novas tasks são criadas. Quando fica abaixo, tasks são removidas respeitando o mínimo de 2.

### Monitorar Auto Scaling
```bash
# Verificar métricas de scaling
aws application-autoscaling describe-scaling-activities --service-namespace ecs

# Status atual do scaling target
aws application-autoscaling describe-scalable-targets --service-namespace ecs
```

## Nomenclatura (Seguindo Regras BIA)

### ECS Resources
- **Cluster:** `cluster-bia-alb`
- **Task Definition:** `task-def-bia-alb`
- **Service:** `service-bia-alb`

### Security Groups
- **ALB:** `bia-alb`
- **EC2:** `bia-ec2` 
- **Database:** `bia-db`

### Outros Recursos
- **RDS:** `bia-db`
- **ALB:** `bia-alb`
- **Auto Scaling Group:** `bia-ecs-asg`

## Pré-requisitos

### Ferramentas Necessárias
- **Terraform** >= 1.0
- **AWS CLI** configurado com credenciais
- **Docker** para build da aplicação
- **Git** para clonar o código da aplicação

### Código da Aplicação BIA
Este projeto Terraform inclui o código fonte completo da aplicação BIA. 

**Repositório original:** https://github.com/caiocf/bia

Todos os arquivos necessários já estão incluídos neste diretório `projeto-terraform`.

## Como Usar

### 1. Inicializar Terraform
```bash
cd projeto-terraform
terraform init
```

### 2. Planejar a Infraestrutura
```bash
terraform plan
```

### 3. Aplicar a Infraestrutura
```bash
terraform apply
```

### 4. Deploy da Aplicação

#### 4.1 Preparar Código da Aplicação
```bash
# Copiar arquivos necessários para o diretório terraform
cp ../package*.json ./
cp -r ../client ./
cp -r ../api ./
cp -r ../config ./
cp -r ../database ./
cp ../index.js ../server.js ./
```

#### 4.2 Login no ECR
```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL
```

#### 4.3 Build e Push da Imagem
```bash
# Build da imagem Docker
docker build -t bia .
docker tag bia:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

#### 4.4 Forçar Nova Implantação
```bash
aws ecs update-service --cluster cluster-bia-alb --service service-bia-alb --force-new-deployment
```

### 5. Acessar a Aplicação
```bash
# Obter URL do ALB
terraform output alb_url

# Testar aplicação
curl $(terraform output -raw alb_url)/api/versao
```

## Outputs Importantes

| Output | Descrição |
|--------|-----------|
| `alb_url` | URL completa do Application Load Balancer |
| `alb_dns_name` | DNS name do ALB |
| `ecr_repository_url` | URL do repositório ECR |
| `rds_endpoint` | Endpoint do banco PostgreSQL |
| `ecs_cluster_name` | Nome do cluster ECS |
| `ecs_service_name` | Nome do serviço ECS |

## Configurações

### Variáveis Principais
```hcl
aws_region     = "us-east-1"
project_name   = "bia"
environment    = "dev"
db_username    = "postgres"
db_password    = "postgres123"
container_port = 8080
```

### Tipos de Instância (Seguindo Regras BIA)
- **EC2:** t3.micro (simplicidade educacional)
- **RDS:** db.t3.micro (custo-efetivo)

## Security Groups (Regras BIA)

### bia-alb (ALB)
- **Inbound:** HTTP (80) e HTTPS (443) de 0.0.0.0/0
- **Outbound:** All traffic

### bia-ec2 (EC2 Instances)
- **Inbound:** All TCP de bia-alb (portas dinâmicas ECS)
- **Outbound:** All traffic

### bia-db (Database)
- **Inbound:** PostgreSQL (5432) de bia-ec2
- **Outbound:** All traffic

## Monitoramento

### Health Check
- **Path:** `/api/versao`
- **Expected Response:** `"Bia 4.2.0"`
- **Interval:** 30 segundos
- **Timeout:** 5 segundos

### Verificar Status
```bash
# Status do serviço ECS
aws ecs describe-services --cluster cluster-bia-alb --services service-bia-alb

# Tasks em execução
aws ecs list-tasks --cluster cluster-bia-alb --service-name service-bia-alb

# Health do ALB
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)
```

## Estrutura do Projeto

```
projeto-terraform/
├── main.tf                    # Configuração principal do Terraform
├── variables.tf               # Variáveis do projeto
├── terraform.tfvars.example   # Exemplo de variáveis
├── outputs.tf                 # Outputs do Terraform
├── ecs.tf                    # Configuração ECS (Cluster, Service, Task)
├── autoscaling.tf            # Auto Scaling do ECS Service
├── alb.tf                    # Application Load Balancer
├── security_groups.tf        # Security Groups
├── iam.tf                    # IAM Roles e Policies
├── rds.tf                    # Banco PostgreSQL
├── ecr.tf                    # Elastic Container Registry
├── Dockerfile                # Container da aplicação BIA
├── .gitignore               # Arquivos ignorados pelo Git
├── README.md                # Esta documentação
├── package*.json            # Dependências Node.js
├── index.js                 # Arquivo principal da aplicação
├── server.js                # Servidor da aplicação
├── client/                  # Frontend React
├── api/                     # APIs do backend
├── config/                  # Configurações
└── database/                # Migrations e seeds
```

## Reprodução Completa do Ambiente

### Passo a Passo Completo

#### 1. Clonar e Preparar Ambiente
```bash
# Clonar o repositório BIA
git clone https://github.com/caiocf/bia.git
cd bia/projeto-terraform
```

#### 2. Configurar AWS CLI
```bash
# Configurar credenciais AWS (se ainda não configurado)
aws configure
```

#### 3. Provisionar Infraestrutura
```bash
# Configurar variáveis (copiar do exemplo)
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars se necessário

# Inicializar Terraform
terraform init

# Revisar o plano
terraform plan

# Aplicar infraestrutura
terraform apply -auto-approve
```

#### 4. Deploy da Aplicação
```bash
# Obter URL do ECR
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login no ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Build e push da imagem
docker build -t bia .
docker tag bia:latest $ECR_URL:latest
docker push $ECR_URL:latest

# Forçar deploy no ECS
aws ecs update-service --cluster cluster-bia-alb --service service-bia-alb --force-new-deployment
```

#### 5. Verificar Aplicação
```bash
# Aguardar alguns minutos e testar
ALB_URL=$(terraform output -raw alb_url)
curl $ALB_URL/api/versao

# Deve retornar: "Bia 4.2.0"
```

## Reprodução Completa do Ambiente

### Problemas Comuns

#### 1. Task não inicia
```bash
# Verificar eventos do serviço
aws ecs describe-services --cluster cluster-bia-alb --services service-bia-alb --query 'services[0].events[0:5]'
```

#### 2. 502 Bad Gateway
- Aguardar health check do ALB (até 2 minutos)
- Verificar se container está rodando na porta 8080

#### 3. Erro de conectividade com RDS
- Verificar security groups
- Confirmar endpoint do banco nas variáveis de ambiente

## Custos Estimados (us-east-1)

### Recursos e Custos Mensais Aproximados
- **EC2 t3.micro (2-6 instâncias):** $8.50 - $25.50/mês
- **RDS db.t3.micro:** $12.41/mês
- **Application Load Balancer:** $16.20/mês
- **ECR Storage:** ~$1.00/mês (para algumas imagens)
- **Data Transfer:** Variável conforme uso

**Total Estimado:** $38 - $55/mês

⚠️ **Importante:** Estes são valores aproximados. Use o [AWS Pricing Calculator](https://calculator.aws) para estimativas precisas.

## Limpeza

### Destruir Infraestrutura
```bash
terraform destroy
```

**⚠️ Atenção:** Isso removerá todos os recursos criados, incluindo o banco de dados.

## Filosofia do Projeto

Este Terraform segue a **filosofia educacional do projeto BIA**:
- ✅ **Simplicidade** acima de complexidade
- ✅ **Recursos básicos** para aprendizado
- ✅ **Nomenclatura consistente**
- ✅ **Configurações t3.micro** (custo-efetivo)
- ❌ **Sem recursos avançados** (Secrets Manager, Multi-AZ, etc.)

## Suporte

Para dúvidas sobre este projeto Terraform:
1. Verificar logs do Terraform: `terraform show`
2. Consultar documentação AWS ECS
3. Abrir issue no repositório: https://github.com/caiocf/bia

**Repositório:** https://github.com/caiocf/bia  
**Autor:** Caio Cesar Ferreira
