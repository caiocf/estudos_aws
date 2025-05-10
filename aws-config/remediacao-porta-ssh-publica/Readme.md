# 🔐 Remediação automática de Security Group com porta 22 aberta usando AWS Config + SSM Automation

Este guia demonstra como **remediar automaticamente Security Groups que possuem a porta TCP 22 aberta para 0.0.0.0/0**, usando:

✅ **AWS Config Rule (`INCOMING_SSH_DISABLED`)**  
✅ **SSM Automation Document customizado**  
✅ **Binding automático do `RESOURCE_ID` no parâmetro `GroupId`**

---

## 🎯 **Cenário**

A organização deseja garantir que **nenhum Security Group permita SSH (porta 22) aberto para o mundo (0.0.0.0/0)**.

Quando um Security Group viola essa política:

1. A **AWS Config detecta a violação** via regra `INCOMING_SSH_DISABLED`
2. Uma **remediação automática é acionada**
3. O **SSM Automation Document executa a remoção da regra insegura**
4. O Security Group volta ao estado **COMPLIANT**

---

## 🏗️ **Arquitetura da solução**

```plaintext
[AWS Config Rule: INCOMING_SSH_DISABLED]
            ↓ (violation detected)
[Remediation Configuration]
            ↓ (parameter binding)
[SSM Automation Document]
            ↓ (executa ação)
[RevokeSecurityGroupIngress no Security Group]
````

---

## ✨ **Passo 1: Criar o documento SSM Automation**

Crie um arquivo chamado `RemovePublicSSH.yml` com o conteúdo abaixo:

```yaml
---
schemaVersion: '0.3'
description: "Remove SSH público de um Security Group"
parameters:
  GroupId:
    type: String
    description: "ID do Security Group a ser remediado"

mainSteps:
  - name: revokeInboundSSH
    action: aws:executeAwsApi
    inputs:
      Service: ec2
      Api: RevokeSecurityGroupIngress
      GroupId: "{{ GroupId }}"
      IpPermissions:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          IpRanges:
            - CidrIp: "0.0.0.0/0"
```

👉 Para criar o documento na AWS, execute:

```bash
aws ssm create-document \
    --name "RemovePublicSSH" \
    --document-type Automation \
    --content file://RemovePublicSSH.yml
```

✅ Isso criará o documento `RemovePublicSSH` no Systems Manager.

> 💡 **Dica:** Você também pode criar o documento manualmente no Console do AWS Systems Manager → Documents → Create Document → Type = Automation → cole o YAML.

---

## ✨ **Passo 2: Criar a regra AWS Config + Remediation Configuration**

Crie um arquivo `remediation.yaml` com o conteúdo abaixo:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: "Remediation automática de Security Group SSH aberto via AWS Config + SSM Automation"

Resources:
  IncomingSSHDisabledRule:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: incoming-ssh-disabled
      Source:
        Owner: AWS
        SourceIdentifier: INCOMING_SSH_DISABLED

  SSHOpenRemediationSSM:
    Type: AWS::Config::RemediationConfiguration
    Properties:
      ConfigRuleName: !Ref IncomingSSHDisabledRule
      TargetType: SSM_DOCUMENT
      TargetId: "RemovePublicSSH"  # Nome do documento SSM Automation
      Automatic: true
      Parameters:
        GroupId:  # Nome do parâmetro esperado no documento SSM
          ResourceValue:
            Value: RESOURCE_ID  # Faz o binding do RESOURCE_ID para o GroupId
```

👉 Para criar os recursos na sua conta, execute:

```bash
aws cloudformation create-stack \
    --stack-name ssh-remediation-stack \
    --template-body file://remediation.yaml \
    --capabilities CAPABILITY_NAMED_IAM
```

✅ Isso criará:

* A regra **`incoming-ssh-disabled`** no AWS Config
* A configuração de remediação automática vinculada ao documento SSM

> 💡 **Dica:** Você também pode criar o stack via Console → CloudFormation → Create Stack → Upload a template.

---

## ✨ **Passo 3: Ativar AWS Config (caso ainda não esteja ativo)**

Se o AWS Config ainda não está configurado:

1. Acesse **Console AWS Config**
2. Clique **Set up AWS Config**
3. Selecione **todas as regiões ou regiões desejadas**
4. Selecione **gravar configurações de todos os recursos**
5. Crie um bucket S3 ou escolha um existente

✅ Isso garante que o Config possa avaliar os Security Groups.

---

## 📝 **O binding dos parâmetros ocorre aqui:**

```yaml
Parameters:
  GroupId:
    ResourceValue:
      Value: RESOURCE_ID
```

👉 Essa linha **liga automaticamente o ID do Security Group detectado (RESOURCE\_ID) ao parâmetro `GroupId` do documento SSM**.

✅ Quando o Config aciona a remediação, ele **injeta o ID do Security Group nesse parâmetro**, que é usado no documento SSM.

---

## 💥 **Fluxo completo de execução**

1. AWS Config detecta Security Group violando a regra
2. Armazena ID do SG em `RESOURCE_ID`
3. Config usa o binding para mapear `RESOURCE_ID` → `GroupId`
4. Chama o SSM Automation Document com `GroupId = sg-1234567890abcdef0`
5. Documento SSM executa `RevokeSecurityGroupIngress` usando o ID passado
6. Security Group corrigido → Compliance restaurado

---

## ✅ **Benefícios da solução**

* Remediação automática sem intervenção manual
* Escalável para múltiplas contas e regiões
* Totalmente auditável
* Conformidade contínua via AWS Config

---

## 💬 **Dúvidas ou sugestões?**

Abra um **issue ou pull request** para contribuir!

---

👉 Este exemplo segue as **boas práticas recomendadas pela AWS** para governança de Security Groups via AWS Config + SSM Automation.



