# Projeto EKS com Terraform

Este projeto configura um cluster EKS (Elastic Kubernetes Service) usando Terraform e AWS CLI. Siga as instruções abaixo para configurar o ambiente, aplicar a infraestrutura, conectar-se ao cluster e destruir o ambiente, se necessário.

## Pré-requisitos

Antes de iniciar, é necessário instalar as seguintes ferramentas:

- **AWS CLI**: Ferramenta de linha de comando para interação com a AWS. [Guia de instalação](https://docs.aws.amazon.com/pt_br/cli/latest/userguide/getting-started-install.html)
- **kubectl**: Ferramenta de linha de comando para interação com clusters Kubernetes. [Guia de instalação para EKS](https://docs.aws.amazon.com/pt_br/eks/latest/userguide/install-kubectl.html)

## Iniciando o Projeto

1. **Inicialize o Terraform**

   Execute o comando abaixo para inicializar os módulos e plugins necessários:
   ```bash
   terraform init
   ```

2. **Aplique a Configuração**

   Para criar o cluster EKS e os recursos associados, execute:
   ```bash
   terraform apply
   ```
   Confirme a aplicação da infraestrutura quando solicitado.

## Conectando ao Cluster

Após a criação do cluster, utilize os comandos abaixo para configurar e conectar-se a ele:

1. **Configure o kubeconfig**

   Execute este comando para atualizar seu `kubeconfig` e habilitar a conexão com o cluster:
   ```bash
   aws eks update-kubeconfig --region us-east-2 --name meu-cluster-eks
   ```

2. **Verifique os Nós e Pods do Cluster**

   Para ver os nós do cluster, execute:
   ```bash
   kubectl get nodes
   ```

   Para ver todos os pods em todos os namespaces, execute:
   ```bash
   kubectl get pods -A
   ```

## Destruindo o Ambiente

Caso você queira remover todos os recursos criados e destruir a infraestrutura, utilize o comando abaixo:

```bash
terraform destroy
```

Confirme a destruição quando solicitado. Esse comando irá remover todos os recursos provisionados pelo Terraform para este projeto.
