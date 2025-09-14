Gerar Certificados Para Mutual authentication:

Siga os passo, conforme a doc oficial:
https://docs.aws.amazon.com/pt_br/vpn/latest/clientvpn-admin/client-auth-mutual-enable.html

Fazer a listagem de comando usando o Git Bash (Caso esteja usando o Windows):

1. **Clone o repositório OpenVPN easy-rsa para o seu computador local e navegue até a pasta easy-rsa/easyrsa3.**
   ```shell
   git clone https://github.com/OpenVPN/easy-rsa.git
   cd easy-rsa/easyrsa3
   ```

2. **Inicialize um novo ambiente PKI**
   ```shell
   ./easyrsa init-pki
   ```

3. **Para construir uma nova autoridade certificadora (CA), execute este comando e siga as instruções.**
   ```shell
   ./easyrsa build-ca nopass
   ```

4. **Gere o certificado e a chave do servidor.**
   ```shell
   ./easyrsa --san=DNS:server build-server-full server nopass
   ```

5. **Gere o certificado e a chave do cliente.**
   Certifique-se de salvar o certificado do cliente e a chave privada do cliente, pois você precisará deles ao configurar o cliente.
   ```shell
   ./easyrsa build-client-full client1.domain.tld nopass
   ```

aws acm import-certificate --certificate fileb://easy-rsa/easyrsa3/pki/issued/server01.crt --private-key fileb://easy-rsa/easyrsa3/pki/private/server.key --certificate-chain fileb://easy-rsa/easyrsa3/pki/ca.crt

Referencia:

https://www.youtube.com/watch?v=JVja4o-3kIk