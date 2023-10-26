
# Infraestrutura AWS com VPC e Sub-redes Públicas

Este código Terraform cria uma infraestrutura na AWS que inclui uma Virtual Private Cloud (VPC) e sub-redes públicas distribuídas em várias zonas de disponibilidade. A infraestrutura também inclui uma tabela de roteamento padrão, um Internet Gateway e outras configurações relacionadas.

## Comandos Terraform

Para gerenciar esta infraestrutura, você pode usar os seguintes comandos Terraform:

1. **Inicialização do Diretório:**
   ```shell
   terraform init
   ```

2. **Visualização das Mudanças Planejadas:**
   ```shell
   terraform plan
   ```

3. **Aplicação da Infraestrutura:**
   ```shell
   terraform apply
   ```

4. **Destruir a Infraestrutura (quando não for mais necessária):**
   ```shell
   terraform destroy
   ```

Lembre-se de configurar suas credenciais AWS antes de usar esses comandos.

## Recursos Criados

A infraestrutura inclui os seguintes recursos:

- Uma VPC com um bloco CIDR configurável.
- Três sub-redes públicas distribuídas em diferentes zonas de disponibilidade.
- Tabelas de roteamento e associações de sub-rede para rotear o tráfego.
- Um Internet Gateway para permitir a comunicação com a Internet.
- Tags associadas a recursos para facilitar a identificação.

## Variáveis de Configuração

O código Terraform usa as seguintes variáveis de configuração:

- `region`: A região AWS em que a infraestrutura será criada (padrão: us-east-1).
- `name_vpc`: O nome da VPC e das sub-redes (padrão: VPC-PRODUCT).
- `cidr_vpc`: O bloco CIDR para a VPC (padrão: 10.0.0.0/16).

As variáveis têm validações para garantir que os valores estejam corretos e sigam as melhores práticas.

## Saídas

O código Terraform fornece as seguintes saídas:

- `vpc_id`: O ID da VPC criada.
- `vpc_arn`: O ARN da VPC criada.
- `cidr_block`: O bloco CIDR da VPC.
- `subnet_a_id`, `subnet_b_id`, `subnet_c_id`: Os IDs das sub-redes públicas criadas.

Isso facilita o acesso às informações da infraestrutura após a criação.

---

**Observação**: Certifique-se de revisar as mudanças planejadas antes de aplicar qualquer alteração na infraestrutura e destruir recursos somente quando não forem mais necessários.
