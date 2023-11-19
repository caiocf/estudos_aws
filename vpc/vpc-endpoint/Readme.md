# Projeto VPC Endpoint com EC2, NLB e Integração S3

## Descrição
Este projeto demonstra a criação e configuração de VPC Endpoints (tanto do tipo Interface quanto Gateway), Network Load Balancer (NLB), Target Group, e a integração entre a instância EC2 e serviços AWS como S3 e SSM. A instância EC2 usa uma IAM Role para assumir permissões necessárias para interagir com o S3 e é configurada dentro de uma VPC privada. Os VPC Endpoints criados incluem Gateway Endpoints para o Amazon S3 e o Amazon DynamoDB, e Interface Endpoints para SSM, EC2 Messages, SSM Messages e Logs.

## Objetivos
- Implementar Network Load Balancer (NLB) e Target Group.
- Configurar uma IAM Role com permissões para SSM e S3, que será assumida pela instância EC2.
- Criar VPC Endpoints do tipo Gateway para Amazon S3 e DynamoDB.
- Criar VPC Endpoints do tipo Interface para SSM, EC2 Messages, SSM Messages e Logs.
- Criar VPC Endpoints VPC Endpoint Service na VPC A e VPC Endpoint Interface na VPC B com Hosted Zone Private
- Operar todos os recursos dentro de uma VPC privada com NAT Instance.

## Como Testar
Para verificar a funcionalidade do projeto, você pode:
1. Acessar a instância EC2 via AWS Systems Manager (SSM).
2. Executar comandos para testar a conectividade e o funcionamento dos VPC Endpoints.
3. Utilizar o comando `aws s3 ls meu-bucket-16-11-2100` para listar os conteúdos do bucket S3 configurado.

## Pré-requisitos
- AWS CLI configurado com as credenciais apropriadas.
- Conhecimento básico de VPC, EC2, AWS Network Load Balancer, Amazon S3, DynamoDB e AWS Systems Manager.

## Configuração e Implantação
1. **VPC e NAT Instance**:
    - Crie uma VPC privada.
    - Configure o NAT Instance para permitir o acesso à internet.

2. **VPC Endpoints**:
    - **Gateway Endpoint para S3 e DynamoDB**:
        - Crie Gateway Endpoints específicos para o Amazon S3 e o Amazon DynamoDB dentro da VPC.
    - **Interface Endpoint para SSM/EC2 Messages/SSM Messages/Logs**:
        - Crie Interface Endpoints específicos para SSM, EC2 Messages, SSM Messages e Logs.

3. **NLB, Target Group e EC2**:
    - Configure o NLB e o Target Group.
    - Crie uma instância EC2 e associe-a ao Target Group.
    - Crie um bucket S3 (`meu-bucket-16-11-2100`).
    - Associe uma IAM Role à instância EC2 com permissões para SSM e S3.

4. **Como Testar VPC Endpoint Interface e Gateway**:
Para verificar a funcionalidade do projeto, execute os seguintes comandos na instância EC2:
Utilize o AWS Systems Manager (SSM) para acessar a instância EC2 de nome "web_Vpc_A_Private" e realizar esses testes.

   ```bash
    sh-4.2$ ping ec2messages.us-east-1.amazonaws.com
    PING ec2messages.us-east-1.amazonaws.com (10.0.20.246) 56(84) bytes of data.
    ^C
    --- ec2messages.us-east-1.amazonaws.com ping statistics ---
    2 packets transmitted, 0 received, 100% packet loss, time 1000ms
    sh-4.2$ curl https://ec2messages.us-east-1.amazonaws.com
    <UnknownOperationException/>
    sh-4.2$
    sh-4.2$ aws s3 ls meu-bucket-16-11-2100
    2023-11-19 15:37:19         12 meuArquivo.txt
    sh-4.2$
    ```
4. **Como Testar VPC Endpoint Load Balancer com Private Zone da VPC_b á VPC_A**:
   Para verificar a funcionalidade do projeto, execute os seguintes comandos na instância EC2:
   Utilize o AWS Systems Manager (SSM) para acessar a instância EC2 de nome "web_Vpc_B_Private" e realizar esses testes.

   ```bash
    sh-4.2$ curl http://ptfe.vpc.internal
    web_Vpc_A_Private
    sh-4.2$
    ```   
