
Este projeto realiza a criação de uma um VPN site-to-site na AWS com o pfsense (https://www.pfsense.org/download/).

Rede AWS criada:
172.31.0.0/16

Rede PF-Sense Cliente:
192.168.24.0/24


Primeiro passao é cria os recursos na AWS e baixar configurações para o PFSense e configurar no GUI apos a instalação do mesmo no Virtualbox.
```shell
terraform init
terraform apply
```

Criação da Rede da Rede Host Only VirtualBox (sem servidor dhcp):
![rede_host_only_virtualbox.PNG](figuras%2Frede_host_only_virtualbox.PNG)

Foi instalado o pf-sense no virtualbox com duas interfaces de rede.
Senda o adaptador 1 no modelo brigde
Senda o adaptador 2 no modo host-only
![config_rede_adaptador_pfsense.png](figuras/config_rede_adaptador_pfsense.png)

Realizar a configurações na tela Web do PF Sense no menu IPSec, conforme orientação do txt da AWS.
![configura_tunnel_pfsense.png](figuras%2Fconfigura_tunnel_pfsense.png)

Teste de conexão da AWS para o OnPremisse:

![aws_to_onpremisse.png](figuras%2Faws_to_onpremisse.png)

Teste de conexão do OnPremisse para a AWS:

![onPremisse_to_AWS.png](figuras%2FonPremisse_to_AWS.png)

Referencias:

https://www.youtube.com/watch?v=-C9mwejA4oA

https://www.youtube.com/watch?v=sVACqxLZQG4

https://www.youtube.com/watch?v=Y-Lz7mWzHpQ