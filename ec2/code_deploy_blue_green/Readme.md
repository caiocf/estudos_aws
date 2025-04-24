               +---------------------+
               |    CodeDeploy       |
               +---------------------+
                        |
                        v
         +----------------------------+
         | Application Load Balancer |
         +----------------------------+
                  /          \
                 /            \
         +-----------+   +-----------+
         | TargetGroup A| |TargetGroup B|
         +-----------+   +-----------+
             |                |
       +-----------+    +-----------+
       | EC2 Blue  |    | EC2 Green |
       |  (nginx)  |    |  (nginx)  |
       +-----------+    +-----------+





### Pré-Requisitos
- Terraform v0.12 ou superior.
- Acesso configurado à AWS CLI e Terraform com permissões adequadas.
### Recurso criados

- VPC + Subnet pública
- Application Load Balancer (ALB)
- Target Groups "blue" e "green"
- Launch Template com user_data para instalar NGINX
  - Script install_nginx.sh + start_nginx.sh
    - appspec.yml para CodeDeploy
    - Output com o DNS do ALB

### Como Executar

#### 1. Inicialização do Terraform
Para preparar o Terraform para execução, utilize:
```bash
terraform init
```

#### 2. Planejamento do Terraform
Para revisar as mudanças propostas antes da aplicação, execute:
```bash
terraform plan
```

#### 3. Aplicação das Alterações
Para criar a infraestrutura especificada, execute:
```bash
terraform apply
```

### Limpeza dos Recursos
Quando os recursos não forem mais necessários, utilize o comando abaixo para evitar custos desnecessários:
```bash
terraform destroy
```