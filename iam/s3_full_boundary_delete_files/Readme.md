# Terraform Project: Cross-Account IAM Role with Permission Boundary

Este projeto Terraform cria uma **IAM Role** na AWS com permissões de acesso total ao **Amazon S3** (exceto deletar objetos) e permite que a **conta root de outra conta AWS** assuma essa role.

## Funcionalidades

- **Cross-Account IAM Role**: Define uma role com relação de confiança que permite que a conta root de outra conta AWS assuma essa role.
- **Permissão Completa ao S3 com Restrição de Exclusão**: A role recebe a política `AmazonS3FullAccess`, mas um **Permission Boundary** limita as ações, impedindo que objetos no S3 sejam deletados.
- **Segurança e Governança**: Utiliza Permission Boundary para garantir o princípio do menor privilégio, controlando ações destrutivas no S3.

## Estrutura do Projeto

```plaintext
.
├── main.tf            # Arquivo principal para a configuração da role e do boundary
├── variables.tf       # Definição das variáveis, como o ID da conta de confiança
└── provider.tf        # Configuração do provider AWS
```

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) instalado na máquina.
- Credenciais configuradas no ambiente para provisionar recursos na AWS.

## Variáveis

- `trusted_account_id`: ID da conta AWS que terá permissão para assumir a role (geralmente a conta root da conta de confiança).

## Uso

1**Inicialize o Terraform**:

   Execute o comando abaixo para inicializar o projeto e baixar os providers necessários.

   ```bash
   terraform init
   ```

2**Execute o Terraform Apply**:

   Ao executar o comando `apply`, passe o ID da conta que será confiável para a role (substitua `123456789012` pelo ID da conta):

   ```bash
   terraform apply -var="trusted_account_id=975049978641"
   ```

3**Destruir

Ao executar o comando `destroy` para excluir recursos criados:

   ```bash
   terraform destroy -var="trusted_account_id=975049978641"
   ```

