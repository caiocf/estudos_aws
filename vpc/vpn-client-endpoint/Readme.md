# Projeto: AWS VPN Endpoint com Mutual Authentication

## Objetivo
Este projeto tem como objetivo configurar um AWS VPN Endpoint utilizando o método de autenticação mútua (Mutual Authentication).

## Requisitos
- **Criação de Cadeia de Certificados**: Siga as instruções disponíveis no documento [Criar Cadeia de Certificados](Geracao_Certificados_Para_Mutual_Authentication.md) para gerar a cadeia necessária de certificados.

## Componentes Criados pelo Projeto
1. **VPN AWS**: Configuração e criação de um endpoint de VPN na AWS.
2. **Importação de Cadeia de Certificados**: Importação dos certificados necessários para a autenticação mútua.
3. **Configuração do Endpoint da VPN AWS**: Finalização da configuração do endpoint da VPN.

## Execução com Terraform
Para iniciar o projeto e criar os recursos na AWS, execute os seguintes comandos no terminal:

```shell
terraform init
terraform apply

aws --region us-east-1 ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id cvpn-endpoint-04eb81d43a3de82d8 --output text > client-config.ovpn && sh update_vpn_config.sh client-config.ovpn

```

## Configuração do Cliente VPN
Após a aplicação do Terraform, proceda com as seguintes etapas:

1. **Instalação do Cliente VPN**: Baixe e instale o cliente OpenVPN no seu sistema operacional a partir do site oficial: [OpenVPN Client Download](https://openvpn.net/client/).
2. **Importação do Arquivo de Configuração**: Importe o arquivo `client-config.ovpn`, gerado após a execução do comando `terraform apply`.

## Acesso via SSH
Para conectar via SSH a um recurso na VPC, utilize o seguinte comando (substitua `minhaChave.pem` e o IP pelo seu arquivo de chave e endereço IP correspondentes):

```shell
ssh -i minhaChave.pem ec2-user@172.31.10.129
```

## Destruir recursos no final
```shell
terraform destroy
```


