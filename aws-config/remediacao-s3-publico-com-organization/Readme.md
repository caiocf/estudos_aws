# **Garantindo Compliance Automático com AWS Config e Conformance Packs**

Este guia mostra como implementar uma **estratégia de compliance automatizado usando AWS Config e AWS Config Conformance Packs**, garantindo **monitoramento de configurações, aplicação de boas práticas e remediação automática** em múltiplas contas e regiões da AWS.

---

## 🎯 **Cenário real**

Uma empresa de mídia com **múltiplas contas AWS** quer:

✅ Garantir compliance com políticas de segurança em todos os ambientes
✅ Monitorar configurações e aplicar boas práticas de segurança
✅ Remediar automaticamente recursos não conformes (ex.: S3 públicos, EBS não criptografados)
✅ Consolidar os resultados de compliance em uma conta central

---

## 🏗️ **Arquitetura simplificada**

```plaintext
                 +--------------------------+
                 |   AWS Config Aggregator   |
                 |   (conta central)         |
                 +--------------------------+
                            /   |   \
                           /    |    \
                +----------+  +----------+  +----------+
                | Conta 1  |  | Conta 2  |  | Conta 3  |
                | Config   |  | Config   |  | Config   |
                +----------+  +----------+  +----------+
```

---

## ✨ **Passo 1: Ativar AWS Config em todas as contas**

Ative o AWS Config com **AWS Organizations** usando o **aggregator** na conta central de segurança:

```bash
aws configservice put-configuration-aggregator \
    --configuration-aggregator-name OrgAggregator \
    --organization-aggregation-source OrganizationArn=arn:aws:organizations::123456789012:organization/o-abcxyz,AllAwsRegions=true
```

✅ Isso permitirá consolidar o status de compliance de todas as contas e regiões.

---

## ✨ **Passo 2: Criar regras de compliance**

### Exemplo de regra gerenciada para evitar S3 público:

```yaml
Resources:
  PublicReadProhibitedRule:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: s3-bucket-public-read-prohibited
      Source:
        Owner: AWS
        SourceIdentifier: S3_BUCKET_PUBLIC_READ_PROHIBITED
```

✅ Esta regra verifica se buckets S3 estão públicos.

---

## ✨ **Passo 3: Ativar remediação automática**

Configure a **remediação automática** usando um documento SSM gerenciado pela AWS:

```yaml
Resources:
  S3PublicReadRemediation:
    Type: AWS::Config::RemediationConfiguration
    Properties:
      ConfigRuleName: s3-bucket-public-read-prohibited
      TargetType: SSM_DOCUMENT
      TargetId: AWS-DisableS3BucketPublicReadWrite
      Automatic: true
      Parameters:
        BucketName:
          ResourceValue:
            Value: RESOURCE_ID
```

✅ Quando detectado um bucket público, o Config executará o documento **`AWS-DisableS3BucketPublicReadWrite`** automaticamente para corrigir.

---

## ✨ **Passo 4: Aplicar um Conformance Pack**

Para aplicar **um conjunto de boas práticas recomendado pela AWS** (ex.: Security Best Practices):

```bash
aws configservice put-conformance-pack \
    --conformance-pack-name SecurityBestPracticesPack \
    --template-s3-uri s3://mybucket/config-packs/security-best-practices.yaml
```

✅ O Conformance Pack agrupa várias regras de compliance e pode ser aplicado **globalmente**.

---

## ✅ **Benefícios da solução**

✔️ Visibilidade centralizada das configurações em todas as contas/regiões
✔️ Aplicação automática de políticas de compliance
✔️ Correção automática de não conformidades
✔️ Escalabilidade com AWS Organizations e Config Aggregator
✔️ Suporte para frameworks de compliance (CIS, PCI DSS, NIST)

---

## 📝 **Exemplo de conformidade verificada automaticamente**

* Nenhum bucket S3 público
* Todos os volumes EBS criptografados
* Logging habilitado no CloudTrail
* MFA ativado para contas root

---

## 💬 **Dúvidas ou contribuições?**

Sinta-se à vontade para abrir um **issue ou pull request** com perguntas ou sugestões de melhoria!

---

👉 **Este guia é baseado em práticas recomendadas da AWS para ambientes multi-conta com AWS Organizations.**
