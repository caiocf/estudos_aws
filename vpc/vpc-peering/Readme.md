# Projeto VPC Peering com Terraform

## Sobre
Este projeto cria uma infraestrutura de nuvem automatizada usando Terraform, configurando duas VPCs (Virtual Private Clouds) em regiões diferentes (`us-east-1` e `us-east-2`). Para cada VPC, uma máquina virtual (VM) é criada e configurada com regras de firewall que permitem tráfego nas portas 22 (SSH) e ICMP (PING). Uma chave SSH comum é utilizada para o acesso a ambas as VMs. Um peering de VPC é estabelecido entre as duas VPCs, configurado para autoaceitação e com resolução de DNS habilitada, permitindo a comunicação direta entre as VMs através de SSH ou PING.

## Recursos Criados
- Duas VPCs em regiões diferentes (`us-east-1` e `us-east-2`).
- Duas máquinas virtuais, uma em cada VPC.
- Regras de firewall permitindo tráfego nas portas 22 (SSH) e 80 (HTTP).
- Uma chave SSH comum para ambas as VMs.
- Peering de VPC entre as duas VPCs, com autoaceitação e resolução de DNS habilitada.
- Regras de roteamento ajustadas para permitir comunicação entre as VPCs.

## Pré-Requisitos
- Terraform v0.12+ instalado.

## Como Executar

### 1. Inicialização do Terraform
```bash
terraform init
```

### 2. Planejamento do Terraform
Para revisar as alterações planejadas antes de aplicá-las:
```bash
terraform plan
```

### 3. Aplicação das Alterações
Para criar os recursos na nuvem:
```bash
terraform apply
```

## Testando a Conexão

Com a aplicação das configurações e o peering configurado para autoaceitação e resolução de DNS, você pode testar a conectividade entre as duas VMs.

### Acessar via SSH
Para acessar a VM na outra região via SSH, use o comando:

```bash
ssh -i /caminho/para/sua/chave_privada.pem usuario@nome_dns_da_vm_destino
```

Substitua `/caminho/para/sua/chave_privada.pem` pelo caminho da sua chave SSH e `usuario@nome_dns_da_vm_destino` pelas credenciais e pelo nome DNS apropriados da VM de destino.

## Contribuindo
Contribuições para melhorar a configuração, adicionar novos recursos ou corrigir bugs são sempre bem-vindas.

