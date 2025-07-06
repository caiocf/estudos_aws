# 🛡️ Lambda Token Green

Projeto de estudo utilizando **Quarkus 3** para criação de uma AWS Lambda do tipo **Custom Authorizer** (Token-based) com o runtime **Java 21**. A função é destinada a validar tokens e autorizar requisições no API Gateway.

> ⚠️ Este projeto **não utiliza GraalVM / Native build**, focando exclusivamente em deploy JVM (Java 21).

---

## ✅ Etapa 0: Criar o projeto com archetype Quarkus

```bash
mvn archetype:generate \
  -DarchetypeGroupId=io.quarkus \
  -DarchetypeArtifactId=quarkus-amazon-lambda-archetype \
  -DarchetypeVersion=3.8.1 \
  -DgroupId=br.com.mkcf \
  -DartifactId=lambdatokengreen \
  -Dversion=1.0.0-SNAPSHOT \
  -Dpackage=br.com.mkcf \
  -DinteractiveMode=false
````

---

## 🧪 Rodando localmente (Mock HTTP)

```bash
mvn compile quarkus:dev
```

Envio de evento mock:

```bash
curl -X POST http://localhost:8082 \
  -H "Content-Type: application/json" \
  -d '{
    "type": "TOKEN",
    "authorizationToken": "allow",
    "methodArn": "arn:aws:execute-api:us-east-1:123456789012:abcdef/test/GET/my-resource"
  }'
```

---

## ⚙️ Etapa 1: Build para AWS Lambda

### Build com runtime Java (não-native):

```bash
mvn clean package
```

> Isso gerará o artefato `target/function.zip` com runtime Java 21 configurado no `sam.jvm.yaml`.

---

## 🧪 Teste local com AWS SAM

```bash
sam local invoke \
  --template sam.jvm.yaml \
  --event event.json
```

---

## ☁️ Etapa 2: Deploy na AWS Lambda

### Pré-requisitos

* AWS CLI configurado (`aws configure`)
* IAM Role com permissões básicas: `AWSLambdaBasicExecutionRole`

### Criar função Lambda

```bash
aws lambda create-function \
  --function-name LambdaTokenAuthorizer \
  --handler not.used.in.native.mode \
  --runtime provided.al2 \
  --zip-file fileb://target/function.zip \
  --role arn:aws:iam::<SEU_ID_CONTA>:role/<NOME_ROLE> \
  --environment Variables="{DISABLE_SIGNAL_HANDLERS=true}" \
  --timeout 10 \
  --memory-size 512
```

---

## 🔗 Referências

* [Guia Quarkus Lambda](https://quarkus.io/guides/aws-lambda#deploy-to-aws-lambda-custom-native-runtime)
* [Lambda Authorizer por Alex DeBrie](https://www.alexdebrie.com/posts/lambda-custom-authorizers/)
* [Serverless Java com Quarkus (Medium)](https://medium.com/@ravibiswas0909/serverless-java-3-ways-to-optimize-aws-lambda-with-quarkus-bff5eabb352b)

---

## 📁 Estrutura

```
├── src
│   └── main/java/br/com/mkcf
│       └── AwsLambdaAuthorizer.java
│       └── MyService.java
├── event.json
├── pom.xml
├── sam.jvm.yaml
├── function.zip
└── README.md
```

---

## 📌 Observações

* A anotação `@Named("lambdaAuthorizerMkcf")` pode ser usada para cenários com múltiplas handlers em um mesmo projeto.
* O projeto foi configurado para rodar em `Java 21`, compatível com o runtime `provided.al2` da AWS Lambda.

---


