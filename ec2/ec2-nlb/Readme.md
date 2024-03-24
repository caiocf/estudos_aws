# Projeto Terraform - EC2 com PetStore API e Network Load Balancer

- **Instância EC2**:
    - Criada uma instância EC2 com perfis SSM.
    - A instância executa uma aplicação API RestFull de PetStore com Spring Boot 3 na porta 8080.
    - Foi necessário associar um IP público para que a instância possa baixar o repositório da API do GitHub e instalar o JDK 17, porém as regras de segurança estão bloqueadas.
- **Target Group**:
    - Um Target Group foi criado.
    - A instância EC2 foi associada a este Target Group.
    - Foi configurado um Health Check TCP na porta 8080 para garantir a disponibilidade da instância EC2.

- **Network Load Balancer (NLB)**:
    - Criado um Network Load Balancer do tipo internal.
    - Criado um listener na porta 80 do NLB.
    - O tráfego recebido na porta 80 é encaminhado para o Target Group associado à instância EC2.

- **Security Group**:
    - Criado um Security Group que:
        - Libera a porta 80 para a internet.
        - Libera a porta 8080/TCP para o CIDR padrão da VPC default (para a Aplicação)
        - Libera a porta 22/TCP para o CIDR padrão da VPC default (para acesso SSH).

- **Chave SSH**:
    - Criada uma chave SSH e associada à instância EC2 para acesso seguro via SSH.
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