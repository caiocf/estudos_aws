### Criação dos Recursos

Este projeto cria os seguintes recursos:
- **AWS Secret**: Para armazenar o token do Redis.
- **SSM Parameter Store**: Dois parâmetros para salvar a porta e o endpoint do cluster do Redis.
- **Máquina EC2**: Com `redis-cli` instalado e configurado para usar SSM.
- **Cluster Redis Com Servidor**: Versão 7 com criptografia em trânsito e em repouso, configurado para multi-AZ, 2 node group e uma replica.
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

endpoint_redis = "/elasticache/app-4/app-redis-cluster/endpoint"
port_redis = "/elasticache/app-4/app-redis-cluster/port"
token_redis = "app-4-elasticache-auth"
```

#### Conectando ao Redis

Para conectar ao Redis, você precisa obter o token e o endpoint salvos no SSM e no Secret Manager. Isso pode ser feito via CLI ou console da AWS.

**Obtendo o Endpoint via SSM:**

```shell
aws ssm get-parameter --name "/elasticache/app-4/app-redis-cluster/endpoint" --with-decryption
```

**Exemplo de Resposta:**

```json
{
    "Parameter": {
        "Name": "/elasticache/app-4/app-redis-cluster/endpoint",
        "Value": "clustercfg.app-redis-cluster.g47czi.use1.cache.amazonaws.com"
    }
}
```

**Obtendo o Token via Secrets Manager:**

```shell
aws secretsmanager get-secret-value --secret-id app-4-elasticache-auth
```

**Exemplo de Resposta:**

```json
{
    "SecretString": "sDAVQi1kYeiH2JmQN9wm4jY8HOVjMn859lhXkAimxJTcvrnOdzrdgBiCR8D9VAnk..."
}
```

#### Usando o Redis-CLI na Máquina EC2

Execute os comandos abaixo na máquina EC2 criada com `redis-cli`:

1. Exportar o token do Redis:

    ```shell
    export REDISCLI_AUTH="sDAVQi1kYeiH2JmQN9wm4jY8HOVjMn859lhXkAimxJTcvrnOdzrdgBiCR8D9VAnk..."
    ```

2. Conectar via `redis-cli` no modo cluster:

    ```shell
    redis-cli -c -h clustercfg.app-redis-cluster.g47czi.use1.cache.amazonaws.com -p 6379 --tls
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

Para destruir a infraestrutura no ambiente de desenvolvimento, execute:

```shell
terraform destroy
```

