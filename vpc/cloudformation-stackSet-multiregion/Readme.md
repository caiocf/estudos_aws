# **Deploy de VPC padrão em múltiplas contas e regiões usando AWS CloudFormation StackSets**

Este guia mostra como criar uma **VPC padrão (com subnets públicas e privadas, NAT Gateway, Internet Gateway, etc.) em todas as contas de uma unidade organizacional "Production" em 3 regiões da AWS**, usando **AWS CloudFormation StackSets**.

---

## 🏗️ **Arquitetura simplificada**

```plaintext
                +------------------------+
                | AWS CloudFormation      |
                |        StackSet         |
                +------------------------+
                       /        |        \
                      /         |         \
                  us-east-1   eu-west-1  ap-southeast-1
                    (ACC1)       (ACC2)       (ACC3)
                 [VPC created] [VPC created] [VPC created]
```

---

## ✨ **Passo 1: Criar o template CloudFormation**

Crie um arquivo chamado `vpc-template.yaml` com o seguinte conteúdo:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'VPC padrão com subnets públicas e privadas'

Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: Product-VPC

  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: PublicSubnet-1

  PrivateSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 10.0.2.0/24
      AvailabilityZone: !Select [ 1, !GetAZs '' ]
      Tags:
        - Key: Name
          Value: PrivateSubnet-1
```

---

## ✨ **Passo 2: Criar o StackSet via AWS CLI**

Execute o comando abaixo para criar o StackSet:

```bash
aws cloudformation create-stack-set \
  --stack-set-name "Global-VPC-StackSet" \
  --template-body file://vpc-template.yaml \
  --permission-model SERVICE_MANAGED \
  --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=false
```

### 📝 Notas:

* `SERVICE_MANAGED`: usa integração com **AWS Organizations** (menos esforço operacional)
* `auto-deployment Enabled=true`: aplica o stack automaticamente para **novas contas adicionadas à OU**

---

## ✨ **Passo 3: Implantar o StackSet nas contas da OU**

Execute o comando para criar as instâncias do stack nas contas da OU especificada, em 3 regiões:

```bash
aws cloudformation create-stack-instances \
  --stack-set-name "Global-VPC-StackSet" \
  --deployment-targets OrganizationalUnitIds=ou-xxxx-yyyy \
  --regions us-east-1 eu-west-1 ap-southeast-1
```

Isso implantará o template em **todas as contas da OU "Production" nas regiões indicadas**.

---

## ✅ **Resumo:**

Com este processo:

* Toda nova conta adicionada à OU **receberá automaticamente a VPC padrão provisionada**
* Permite **atualizações centralizadas e automáticas** do template
* Garante **consistência e governança multi-conta e multi-região**

---

## 💬 **Dúvidas ou melhorias?**

Abra um **issue ou pull request** com sugestões ou perguntas! 😉
?
