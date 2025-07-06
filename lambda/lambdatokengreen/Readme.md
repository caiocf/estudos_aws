# 🛡️ Lambda Token Green

Projeto de estudo com **Quarkus 3** para criação de uma AWS Lambda do tipo **Custom Authorizer** (baseado em token), usando o runtime **Java 21**.  
Este projeto recebe um token JWT, valida se ele foi assinado corretamente e se possui um emissor (`iss`) válido.

> ⚠️ Para fins didáticos, a chave de assinatura está hardcoded. Em produção, deve-se utilizar **AWS Secrets Manager** ou **CloudHSM**.

> ⚠️ Este projeto utiliza **JVM (Java 21)**, **sem build nativo com GraalVM**.

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

## 🧪 Execução local (modo desenvolvimento)

```bash
mvn compile quarkus:dev
```

Teste com `curl`:

```bash
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "type": "TOKEN",
    "httpMethod": "GET",
    "headers": {
      "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiaXNzIjoiaHR0cHM6Ly9tZXUtYXV0b3JpemFkb3ItdG9rZW4tZ3JlZW4uY29tIn0.tU8pPcfYcRZ8FtQ7rG2ZL6sMefoYyD1ZMp4QtXqwq-4",
      "User-Agent": "PostmanRuntime/7.32.3"
    },
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
  },
  "context": {
    "authorization": "<novo_token_assinado>",
    "x-authorization": "<token_original_recebido>"
  }
}
```

---

## ⚙️ Build para deploy na AWS Lambda

```bash
mvn clean package
```

> Isso gera o artefato `target/function.zip` com runtime Java 21, conforme definido no `sam.jvm.yaml`.

---

## 🔬 Teste local com AWS SAM

```bash
sam local invoke --template sam.jvm.yaml --event event.json
```

Resposta esperada similar:

```shell
Invoking io.quarkus.amazon.lambda.runtime.QuarkusStreamHandler::handleRequest (java21)
Decompressing lambdatokengreen\target\function.zip
Local image is up-to-date
Using local image: public.ecr.aws/lambda/java:21-rapid-x86_64.

Mounting AppData\Local\Temp\tmpbd102lfc as /var/task:ro,delegated, inside runtime container
START RequestId: 99453e15-75f7-48fc-bf75-f2ca96361b14 Version: $LATEST
__  ____  __  _____   ___  __ ____  ______
 --/ __ \/ / / / _ | / _ \/ //_/ / / / __/
 -/ /_/ / /_/ / __ |/ , _/ ,< / /_/ /\ \
--\___\_\____/_/ |_/_/|_/_/|_|\____/___/
2025-07-06 18:03:27,616 WARN  [io.qua.config] (main) Unrecognized configuration key "quarkus.http.port" was provided; it will be ignored; verify that the dependency extension for this configuration is set or that you did not make a typo
2025-07-06 18:03:29,589 INFO  [io.quarkus] (main) lambdatokengreen 1.0-SNAPSHOT on JVM (powered by Quarkus 3.8.1) started in 8.945s.
2025-07-06 18:03:29,590 INFO  [io.quarkus] (main) Profile prod activated.
2025-07-06 18:03:29,590 INFO  [io.quarkus] (main) Installed features: [amazon-lambda, cdi]
END RequestId: c579d81a-e4ef-4953-a138-d6d42923f342
REPORT RequestId: c579d81a-e4ef-4953-a138-d6d42923f342  Init Duration: 0.07 ms  Duration: 12027.47 ms   Billed Duration: 12028 ms       Memory Size: 1024 MB    Max Memory Used: 1024 MB
{"principalId": "user|a1b2c3", "policyDocument": {"Version": "2012-10-17", "Statement": [{"Condition": null, "Action": "execute-api:Invoke", "Resource": ["arn:aws:execute-api:us-east-1:123456789012:abcdef123/test/GET/my-resource"], "Effect": "Allow"}]}, "context": {"authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJub3ZvLXVzZXIiLCJpc3MiOiJodHRwczovL21ldS1hdXRvcml6YWRvci10b2tlbi1ncmVlbi5jb20iLCJpYXQiOjE3NTE4MjUwMDksImV4cCI6MTc1MTgyODYwOX0.F9x9Y0BF54yBHYsaVII_HSYDGcqQoqz4HH0W-OkndPQ", "x-authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiaXNzIjoiaHR0cHM6Ly9tZXUtYXV0b3JpemFkb3ItdG9rZW4tZ3JlZW4uY29tIn0.tU8pPcfYcRZ8FtQ7rG2ZL6sMefoYyD1ZMp4QtXqwq-4"}}
```

---

## ☁️ Deploy na AWS Lambda

### Pré-requisitos

* `aws configure` com credenciais válidas
* IAM Role com a policy `AWSLambdaBasicExecutionRole`

### Criando a Role

```bash
aws iam create-role \
  --role-name lambda-quarkus-role \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
  --role-name lambda-quarkus-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

### Criando a função Lambda

```bash
aws configure set cli-binary-format raw-in-base64-out

aws lambda create-function \
  --function-name lambdatokengreen \
  --runtime java21 \
  --role $(aws iam get-role --role-name lambda-quarkus-role --query 'Role.Arn' --output text) \
  --handler io.quarkus.amazon.lambda.runtime.QuarkusStreamHandler::handleRequest \
  --memory-size 512 \
  --timeout 15 \
  --zip-file fileb://target/function.zip \
  --region us-east-1
```

---

## ✅ Testes na AWS

### Invocação simples

```bash
aws lambda invoke \
  --function-name lambdatokengreen \
  --payload fileb://event.json \
  --cli-binary-format raw-in-base64-out \
  --region us-east-1 \
  response.json && cat response.json
```

Resposta esperada similar:

```json
{
  "principalId":"user|a1b2c3",
  "policyDocument":{
    "Version":"2012-10-17",
    "Statement":[
      {
        "Condition":null,
        "Action":"execute-api:Invoke",
        "Resource":[
          "arn:aws:execute-api:us-east-1:123456789012:abcdef123/test/GET/my-resource"
        ],
        "Effect":"Allow"
      }
    ]
  },
  "context":{
    "authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJub3ZvLXVzZXIiLCJpc3MiOiJodHRwczovL21ldS1hdXRvcml6YWRvci10b2tlbi1ncmVlbi5jb20iLCJpYXQiOjE3NTE4MjU3MjcsImV4cCI6MTc1MTgyOTMyN30.tpPKJZ5J21QAExIusPdpqw-NeJRp1jYXXhw6rpI1pY8",
    "x-authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiaXNzIjoiaHR0cHM6Ly9tZXUtYXV0b3JpemFkb3ItdG9rZW4tZ3JlZW4uY29tIn0.tU8pPcfYcRZ8FtQ7rG2ZL6sMefoYyD1ZMp4QtXqwq-4"
  }
}
```


### Invocação com log decodificado

```bash
aws lambda invoke \
  --function-name lambdatokengreen \
  --payload fileb://event.json \
  --log-type Tail \
  --query 'LogResult' \
  --output text \
  --cli-binary-format raw-in-base64-out \
  --region us-east-1  response.json | base64 --decode || cat response.json
```


Resposta esperada similar:

```shell
START RequestId: 0b46244c-fb2a-4780-a7ca-3fc8032e9d73 Version: $LATEST
END RequestId: 0b46244c-fb2a-4780-a7ca-3fc8032e9d73
REPORT RequestId: 0b46244c-fb2a-4780-a7ca-3fc8032e9d73  Duration: 5.20 ms       Billed Duration: 6 ms   Memory Size: 512 MB     Max Memory Used: 144 MB
{"principalId":"user|a1b2c3","policyDocument":{"Version":"2012-10-17","Statement":[{"Condition":null,"Action":"execute-api:Invoke","Resource":["arn:aws:execute-api:us-east-1:123456789012:abcdef123/test/GET/my-resource"],"Effect":"Allow"}]},"context":{"authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJub3ZvLXVzZXIiLCJpc3MiOiJodHRwczovL21ldS1hdXRvcml6YWRvci10b2tlbi1ncmVlbi5jb20iLCJpYXQiOjE3NTE4MjU4MjYsImV4cCI6MTc1MTgyOTQyNn0.9Fb_wvbF2Gy3x77q5sRiZfTEsuqGhFz1TS43uF7i5sQ","x-authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiaXNzIjoiaHR0cHM6Ly9tZXUtYXV0b3JpemFkb3ItdG9rZW4tZ3JlZW4uY29tIn0.tU8pPcfYcRZ8FtQ7rG2ZL6sMefoYyD1ZMp4QtXqwq-4"}}
```

---

## ❌ Exclusão de recursos

```bash
aws lambda delete-function \
  --function-name lambdatokengreen \
  --region us-east-1

aws iam detach-role-policy \
  --role-name lambda-quarkus-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam delete-role \
  --role-name lambda-quarkus-role
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
├── target/function.zip
└── README.md
```

---

## 📌 Observações

* Use `@Named("lambdaAuthorizerMkcf")` se quiser múltiplos handlers.
* `@ApplicationScoped` permite CDI com Quarkus.
* O projeto está pronto para deploy em runtime **Java 21** via `provided.al2`.

---

## 🔗 Referências

* [Guia oficial do Quarkus AWS Lambda](https://quarkus.io/guides/aws-lambda)
* [Explicação sobre Custom Authorizers (Alex DeBrie)](https://www.alexdebrie.com/posts/lambda-custom-authorizers/)
* [Serverless Java com Quarkus (Medium)](https://medium.com/@ravibiswas0909/serverless-java-3-ways-to-optimize-aws-lambda-with-quarkus-bff5eabb352b)




