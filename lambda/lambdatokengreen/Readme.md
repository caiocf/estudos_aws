# 🛡️ Lambda Token Green

Projeto de estudo com **Quarkus 3** para criação de uma AWS Lambda do tipo **Custom Authorizer** (baseado em token), usando o runtime **Java 21**.

> ⚠️ Este projeto utiliza **JVM** (Java 21), **sem GraalVM/native build**.

---

## 🔧 Requisitos

- Java 21+
- Docker 20+
- AWS CLI + AWS SAM CLI
- Apache Maven 3.8+

---

## 🚀 Criação do projeto (com archetype Quarkus)

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

## 🧪 Executando localmente (modo desenvolvimento)

```bash
mvn compile quarkus:dev
```

Teste com cURL:

```bash
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "type": "TOKEN",
    "authorizationToken": "allow",
    "methodArn": "arn:aws:execute-api:us-east-1:123456789012:abcdef/test/GET/my-resource"
  }'
```

Resposta esperada:

```json
{
  "principalId": "user|a1b2c3",
  "policyDocument": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "execute-api:Invoke",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:execute-api:us-east-1:123456789012:abcdef/test/GET/my-resource"
        ]
      }
    ]
  }
}
```

---

## ⚙️ Build para deploy na AWS Lambda

```bash
mvn clean package
```

> Gera o artefato `target/function.zip` com runtime Java 21, conforme definido em `sam.jvm.yaml`.

---

## 🔬 Teste local com AWS SAM

```bash
sam local invoke \
  --template sam.jvm.yaml \
  --event event.json
```

Resposta esperada:

```json
START RequestId: 42535255-61f7-4f59-abea-c5a94b25372e Version: $LATEST
__  ____  __  _____   ___  __ ____  ______
--/ __ \/ / / / _ | / _ \/ //_/ / / / __/
-/ /_/ / /_/ / __ |/ , _/ ,< / /_/ /\ \
--\___\_\____/_/ |_/_/|_/_/|_|\____/___/
2025-07-06 02:41:56,014 WARN  [io.qua.config] (main) Unrecognized configuration key "quarkus.http.port" was provided; it will be ignored; verify that the dependency extension for this configuration is set or that you did not make a typo
2025-07-06 02:41:57,824 INFO  [io.quarkus] (main) lambdatokengreen 1.0-SNAPSHOT on JVM (powered by Quarkus 3.8.1) started in 8.249s.
2025-07-06 02:41:57,824 INFO  [io.quarkus] (main) Profile prod activated.
2025-07-06 02:41:57,824 INFO  [io.quarkus] (main) Installed features: [amazon-lambda, cdi]
2025-07-06 02:41:57,853 INFO  [br.com.mkc.AwsLambdaAuthorizer] (main) Authorizing token='allow' for methodArn='arn:aws:execute-api:us-east-1:123456789012:abcdef123/test/GET/my-resource'
END RequestId: c0c3a456-3f9a-4ea0-af75-19b189547e97
REPORT RequestId: c0c3a456-3f9a-4ea0-af75-19b189547e97  Init Duration: 0.05 ms  Duration: 10594.19 ms   Billed Duration: 10595 ms       Memory Size: 1024 MB    Max Memory Used: 1024 MB
{"principalId": "user|a1b2c3", "policyDocument": {"Version": "2012-10-17", "Statement": [{"Condition": null, "Action": "execute-api:Invoke", "Resource": ["arn:aws:execute-api:us-east-1:123456789012:abcdef123/test/GET/my-resource"], "Effect": "Allow"}]}, "context": null}
```

> Isso simula a execução da Lambda com Java 21 (`provided.al2`) em container local.

---

## ☁️ Deploy na AWS Lambda

### Pré-requisitos

* `aws configure` com credenciais válidas
* IAM Role com `AWSLambdaBasicExecutionRole`

### Comando para criar a função:

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

## 📁 Estrutura do projeto

```
├── src/main/java/br/com/mkcf
│   ├── AwsLambdaAuthorizer.java
│   └── MyService.java
├── event.json
├── pom.xml
├── sam.jvm.yaml
├── function.zip
└── README.md
```

---

## 📌 Observações

* Use `@Named("lambdaAuthorizerMkcf")` se quiser configurar múltiplos handlers no mesmo projeto.
* A anotação `@ApplicationScoped` é usada para permitir injeção com CDI no Quarkus.
* Este projeto está pronto para deploy com runtime **Java 21** via `provided.al2`.

---

## 🔗 Referências

* [Guia Oficial do Quarkus Lambda](https://quarkus.io/guides/aws-lambda)
* [Explicação sobre Custom Authorizers (Alex DeBrie)](https://www.alexdebrie.com/posts/lambda-custom-authorizers/)
* [Java Serverless com Quarkus - Medium](https://medium.com/@ravibiswas0909/serverless-java-3-ways-to-optimize-aws-lambda-with-quarkus-bff5eabb352b)

```


