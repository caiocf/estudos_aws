# Projeto Terraform: RDS Oracle na AWS

Este projeto Terraform cria uma configuração robusta de RDS Oracle na AWS, incluindo configurações de multi-região, VPC, segurança e backup automatizado.

## Recursos Criados

Este projeto configura os seguintes recursos na AWS:

- **Provedores AWS**: Configuração para múltiplas regiões AWS.
- **VPC**: Cria uma Virtual Private Cloud com subnets públicas, privadas e de banco de dados.
- **Security Group**: Um grupo de segurança para controlar o acesso ao RDS Oracle.
- **RDS Oracle**: Uma instância RDS Oracle com suporte a múltiplas zonas de disponibilidade, backup automatizado e insights de desempenho.
- **KMS**: Uma chave de gerenciamento de chaves (KMS) para backups replicados entre regiões.
- **Backups Automatizados Replicados**: Configuração para replicação de backups automatizados do RDS entre regiões.

## Como Usar

Para aplicar essa configuração, siga os passos abaixo:

### Inicialização

Inicialize o Terraform para instalar os módulos necessários e configurar os provedores:

```bash
terraform init
```

### Aplicação

Para criar os recursos na AWS conforme definido neste projeto, execute:

```bash
terraform apply
```

### Destruição

Para destruir todos os recursos criados por este projeto Terraform, execute:

```bash
terraform destroy
```

## Considerações Importantes

- **Custos AWS**: Este projeto criará recursos que podem gerar custos na AWS. Certifique-se de entender os custos associados e monitore o uso.
- **Segurança**: Verifique as configurações de segurança, especialmente as regras de grupos de segurança e as políticas de acesso.
- **Backups e Recuperação**: Assegure-se de compreender e configurar adequadamente os backups e as estratégias de recuperação.
