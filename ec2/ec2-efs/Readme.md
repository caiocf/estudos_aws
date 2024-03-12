## Projeto Terraform para Infraestrutura AWS

### Sobre
Este projeto Terraform automatiza a configuração de uma infraestrutura AWS robusta, incluindo a implantação de instâncias EC2, configuração de perfis e roles IAM, criar EFS, grupos de segurança, e a monta NFS nas instancias EC2 . É ideal para o deployment de aplicações web que demandam alto desempenho e segurança.

### Recursos Criados
- **Instâncias EC2:** Utiliza uma AMI específica de Linux Amazon, otimizando as instâncias para aplicações web. As instâncias são configuradas para oferecer desempenho e segurança aprimorados. Monta EFS na instancia linux.
- **Perfil de Instância IAM e Role IAM:** Define permissões e políticas de acesso para as instâncias EC2, assegurando um controle de acesso detalhado e aderência às melhores práticas de segurança.
- **Grupo de Segurança:** Estabelece regras de acesso para permitir NFS e SSH, controlando o acesso às instâncias de forma segura e eficaz.
- **Provedores Terraform:** Configura os provedores `aws`, definindo a região e as versões necessárias para a execução do projeto.
- **Dados AWS:** Emprega data sources para selecionar dinamicamente VPCs padrão, subnets e AMIs, facilitando a configuração e o deployment da infraestrutura.
- **Variáveis:** Permite a customização da região AWS onde os recursos serão implantados, proporcionando flexibilidade ao usuário.
- **EFS:** Criar um EFS e monta em todas as subnets da VPC 

### Pré-Requisitos
- Terraform v0.12 ou superior.
- Acesso configurado à AWS CLI e Terraform com permissões adequadas.

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
![montagem_efs_linux.png](montagem_efs_linux.png)

### Limpeza dos Recursos
Quando os recursos não forem mais necessários, utilize o comando abaixo para evitar custos desnecessários:
```bash
terraform destroy
```