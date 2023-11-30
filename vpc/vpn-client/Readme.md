Este projeto tem como objetivo criar um AWS VPN Endpoint do Tipo Mutual Authentication


Requisitos: 
Criar Cadeia de certificados, segue as instruções do arquivo [Criar Cadeia Certificados](Geracao_Certificados_Para_Mutual_Authentication.md)

Items que ele criar:
Criar uma VPN
Importa Cadeia de Certificados
Criar AWS VPN.


```shell
terraform init
terraform apply
```


Baixar o https://openvpn.net/client/ para o S.O e importa o arquivo "client-config.ovpn" gerado depois do comando apply.

```shell
ssh -i minhaChave.pem ec2-user@172.31.10.129
```
