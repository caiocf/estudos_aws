### Criação dos Recursos

Este projeto cria os seguintes recursos:
- **AWS Secret**: Para armazenar o senha do Redis.
- **SSM Parameter Store**: Dois parâmetros para salvar a porta e o endpoint do cluster do Redis.
- ** Criar de usuario e um grupo associação ao cluster redis.
- **Máquina EC2**: Com `redis-cli` instalado e configurado para usar SSM.
- **Cluster Redis Sem Servidor (Serverless)**: Versão 7 com criptografia em trânsito e em repouso
- **VPC Privada**: Criação de uma VPC privada para os recursos.

#### Implantação da Infraestrutura

Para implantar a infraestrutura, execute o seguinte comando:

```shell
terraform apply
```

Você será solicitado a confirmar a ação:

```
Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.

Enter a value: yes
```

Após a execução, os outputs relevantes serão exibidos, como:

```
Outputs:

endpoint_redis = "/elasticache/app-4/app-redis-serverless/endpoint"
port_redis = "/elasticache/app-4/app-redis-serverless/port"
token_secret_manager_redis = "app-4-elasticache-auth-serverless"
username_redis = "redis-user"
```

#### Conectando ao Redis

Para conectar ao Redis, você precisa obter o token e o endpoint salvos no SSM e no Secret Manager. Isso pode ser feito via CLI ou console da AWS.

**Obtendo o Endpoint via SSM:**

```shell
aws ssm get-parameter --name "/elasticache/app-4/app-redis-serverless/endpoint" --with-decryption
```

**Exemplo de Resposta:**

```json
{
    "Parameter": {
        "Name": "/elasticache/app-4/app-redis-serverless/endpoint",
        "Value": "app-redis-serverless-g47czi.serverless.use1.cache.amazonaws.com"
    }
}
```

**Obtendo o Token via Secrets Manager:**

```shell
aws secretsmanager get-secret-value --secret-id app-4-elasticache-auth-serverless
```

**Exemplo de Resposta:**

```json
{
    "SecretString": "V2kGXPPZfTcTCtA3E0LelPHrCAiOQH3v1sMCV0RWYV3y9OsbeVY6DrA6trYZZ928Lxr9gtznQ9hs6AHUCLVsoHsUeUn8Q5QlckCObCClLzkhKJPRku0BuX5MCfk4iUYd"
}
```

#### Usando o Redis-CLI na Máquina EC2

Execute os comandos abaixo na máquina EC2 criada com `redis-cli`:

1. Conectar via `redis-cli` no modo cluster:

 ```shell
redis-cli -c -h app-redis-serverless-g47czi.serverless.use1.cache.amazonaws.com -p 6379 --tls --user redis-user --pass V2kGXPPZfTcTCtA3E0LelPHrCAiOQH3v1sMCV0RWYV3y9OsbeVY6DrA6trYZZ928Lxr9gtznQ9hs6AHUCLVsoHsUeUn8Q5QlckCObCClLzkhKJPRku0BuX5MCfk4iUYd
```

#### Cadastrando e Recuperando Valores

Exemplo de comandos Redis para cadastro e recuperação de valores:

```shell
set a "hello"          # Set key "a" with a string value and no expiration
get a                  # Get value for key "a"
set b "Good-bye" EX 5  # Set key "b" with a string value and a 5 second expiration
get b                  # Get value for key "b"
# wait 5 seconds
get b                  # key has expired
quit                   # Exit from redis-cli
```

#### Destruição da Infraestrutura

Para destruir a infraestrutura no ambiente, execute:

```shell
terraform destroy
```

