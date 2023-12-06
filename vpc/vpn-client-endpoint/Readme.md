# Projeto VPN Site-to-Site com Terraform e pfSense

Este projeto visa estabelecer uma conexão VPN site-to-site na AWS, utilizando pfSense como solução de firewall e roteamento. O pfSense é uma plataforma de firewall de código aberto altamente configurável, que pode ser obtida em [pfSense Download](https://www.pfsense.org/download/).

## Estrutura de Rede

### AWS Network Setup

A rede configurada na AWS é a seguinte:

- **VPC Network**: `172.31.0.0/16`

### Cliente PF-Sense Network

A rede configurada para o cliente PF-Sense é:

- **Client Network**: `192.168.24.0/24`

## Configuração Inicial

### Passo 1: Configuração dos Recursos na AWS

Para iniciar o projeto, primeiro crie os recursos necessários na AWS. Após a criação, baixe as configurações para o pfSense. Você pode começar com os seguintes comandos Terraform:

```shell
terraform init
terraform apply
```

### Passo 2: Configuração da Rede Host-Only no VirtualBox

Configure a rede Host-Only no VirtualBox sem um servidor DHCP. A figura abaixo ilustra a configuração da rede:

![rede_host_only_virtualbox.PNG](..%2Fvpn-site-to-site%2Ffiguras%2Frede_host_only_virtualbox.PNG)

### Passo 3: Instalação do pfSense no VirtualBox

O pfSense deve ser instalado no VirtualBox com duas interfaces de rede configuradas da seguinte forma:

- **Adaptador 1**: Modo Bridge
- **Adaptador 2**: Modo Host-Only

Veja a configuração das interfaces de rede do pfSense:

![config_rede_adaptador_pfsense.png](..%2Fvpn-site-to-site%2Ffiguras%2Fconfig_rede_adaptador_pfsense.png)

### Passo 4: Configuração do pfSense via GUI

Após a instalação do pfSense, prossiga com as configurações no menu IPSec da interface Web do PF Sense, seguindo as orientações fornecidas pela AWS.

## Testes de Conexão

Para validar a configuração da VPN, realize testes de conexão em ambas as direções:

1. **AWS para On-Premises**

![aws_to_onpremisse.png](..%2Fvpn-site-to-site%2Ffiguras%2Faws_to_onpremisse.png)![Teste de Conexão da AWS para On-Premises](figuras/aws_to_onpremisse.png)

2. **On-Premises para AWS**

![onPremisse_to_AWS.png](..%2Fvpn-site-to-site%2Ffiguras%2FonPremisse_to_AWS.png)


Referencia:
https://www.youtube.com/watch?v=sVACqxLZQG4
https://www.youtube.com/watch?v=Y-Lz7mWzHpQ