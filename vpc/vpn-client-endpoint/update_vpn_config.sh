#!/bin/bash

# Caminhos para os arquivos de certificado e chave
CLIENT_CERT_PATH="custom_folder/client1.domain.tld.crt"
CLIENT_KEY_PATH="custom_folder/client1.domain.tld.key"
CA_CERT_PATH="custom_folder/ca.crt"

# Arquivo de configuração do VPN
#VPN_CONFIG_FILE="client-config.ovpn"
VPN_CONFIG_FILE=$1

# Adicionar o certificado do cliente, chave privada e certificado da CA ao arquivo .ovpn
echo "<cert>" >> $VPN_CONFIG_FILE
cat $CLIENT_CERT_PATH >> $VPN_CONFIG_FILE
echo "</cert>" >> $VPN_CONFIG_FILE

echo "<key>" >> $VPN_CONFIG_FILE
cat $CLIENT_KEY_PATH >> $VPN_CONFIG_FILE
echo "</key>" >> $VPN_CONFIG_FILE

echo "<ca>" >> $VPN_CONFIG_FILE
cat $CA_CERT_PATH >> $VPN_CONFIG_FILE
echo "</ca>" >> $VPN_CONFIG_FILE
