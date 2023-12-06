# Projeto de VPN Site-to-Site na AWS com pfSense

Este projeto envolve a criação de uma VPN site-to-site na AWS, utilizando o pfSense. O pfSense pode ser baixado do [Site Oficial do pfSense](https://www.pfsense.org/download/).

## Estrutura das Redes

- **Rede AWS**: `172.31.0.0/16`
- **Rede PF-Sense Cliente**: `192.168.24.0/24`

## Configuração Inicial

### Passo 1: Configuração na AWS

Crie os recursos necessários na AWS, ajuste o endereço IP público (obtido através de [Meu IP](https://meuip.com.br/)) no arquivo `main.tf` na seção `aws_customer_gateway` do `cgw_main`.

```shell
terraform init
terraform apply
```

### Passo 2: Configuração da Rede no VirtualBox

Crie uma rede Host-Only no VirtualBox (sem servidor DHCP):

![Rede Host-Only VirtualBox](figuras%2Frede_host_only_virtualbox.PNG)

### Passo 3: Instalação do pfSense no VirtualBox

Instale o pfSense no VirtualBox com duas interfaces de rede:

- **Adaptador 1**: Modo Bridge
- **Adaptador 2**: Modo Host-Only

![Configuração do Adaptador pfSense](figuras/config_rede_adaptador_pfsense.png)

## Configuração do pfSense

Configure o pfSense no menu IPSec da interface web, seguindo as orientações da AWS.

![Configuração do Tunnel pfSense](figuras%2Fconfigura_tunnel_pfsense.png)

## Configuração do Firewall

Configure o firewall no pfSense e na AWS para permitir todo o tráfego, para fins didáticos:

- **Rede Local -> AWS**

  ![Firewall Rede Local para AWS](figuras/rule_firewall_redeLocal_to_AWS.png)

- **AWS -> Rede Local**

  ![Firewall AWS para Rede Local](figuras/rule_firewall_AWS_to_redeLocal.png)

- **Security Group AWS da EC2 Criada**

  ![Security Group AWS da EC2](figuras/aws_security_group_ec2.png)

## Testes de Conexão

### AWS para OnPremise

Realize o ping do IP de uma máquina local (OnPremise) a partir de uma máquina virtual na AWS.

![Teste AWS para OnPremise](figuras%2Faws_to_onpremisse.png)

### OnPremise para AWS

Crie uma máquina virtual na rede Host-Only e ajuste o IP local para `192.168.24.100` (endereço da interface pfSense). Realize o ping para uma máquina EC2 na AWS.

- **Configuração da Rede da Máquina Virtual Cliente no VirtualBox**

  ![Configuração da Rede da Máquina Virtual Cliente](figuras/maquina_virutal_cliente_virtuabox_config_rede.png)

![Teste OnPremise para AWS](figuras%2FonPremisse_to_AWS.png)

## Referências

- [Tutorial em Vídeo 1](https://www.youtube.com/watch?v=-C9mwejA4oA)
- [Tutorial em Vídeo 2](https://www.youtube.com/watch?v=sVACqxLZQG4)
- [Tutorial em Vídeo 3](https://www.youtube.com/watch?v=Y-Lz7mWzHpQ)
