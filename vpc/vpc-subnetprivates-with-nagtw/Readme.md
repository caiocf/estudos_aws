**Resumo:**

Este código Terraform cria uma infraestrutura na AWS usando o serviço Amazon Virtual Private Cloud (VPC) e recursos relacionados. A infraestrutura é projetada para suportar uma configuração de rede com sub-redes públicas e privadas, permitindo que instâncias de computação se comuniquem com a Internet de forma segura. A infraestrutura consiste nos seguintes componentes:

- Um provedor AWS configurado com a região especificada.
- Uma VPC com um bloco CIDR definido.
- Três sub-redes privadas distribuídas em diferentes zonas de disponibilidade.
- Tabelas de roteamento privadas associadas às sub-redes privadas.
- Associações entre sub-redes privadas e tabelas de roteamento privadas.
- Três Elastic IPs (EIPs) e NAT Gateways para permitir que as instâncias em sub-redes privadas acessem a Internet.
- Três sub-redes públicas distribuídas em diferentes zonas de disponibilidade.
- Uma rota pública nas tabelas de roteamento padrão da VPC para direcionar o tráfego para o Internet Gateway.
- Associações entre sub-redes públicas e tabelas de roteamento públicas.
- Um Internet Gateway associado à VPC.
- Variáveis para configurar a região AWS e o bloco CIDR da VPC.
- Validações de variáveis para garantir que as configurações estejam corretas.
- Consulta das zonas de disponibilidade disponíveis na região.
- Saídas que fornecem informações sobre os recursos criados.

**Comandos Terraform:**

Aqui estão os comandos Terraform que você usaria para criar e gerenciar esta infraestrutura:

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

Lembre-se de que a sequência de comandos acima pressupõe que você está executando-os no diretório onde o código Terraform está localizado e que você já configurou suas credenciais AWS, geralmente por meio de variáveis de ambiente ou um arquivo de configuração AWS (`~/.aws/credentials`).

Certifique-se de revisar cuidadosamente as mudanças planejadas (`terraform plan`) antes de aplicá-las (`terraform apply`) e tenha cuidado ao destruir recursos, pois isso pode resultar em perda de dados e custos associados.