# Defina a versão do provedor da AWS
provider "aws" {
  region = "us-east-2"  # Defina a região que desejar
}

# Defina a versão do módulo EKS
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "meu-cluster-eks"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = data.aws_vpc.default.id
  subnet_ids               = data.aws_subnets.default.ids
  control_plane_subnet_ids = data.aws_subnets.default.ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  # Parâmetros dos nós do worker
  eks_managed_node_groups  = {
    meu_node_group = {
      ami_type       = "AL2023_x86_64_STANDARD"

      desired_capacity = 2
      max_size         = 3
      min_size         = 1

      instance_type = "t3.medium"
      #key_name      = "minha-keypair"  # Defina sua key pair para acesso SSH, se necessário
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  # Configuração de tags
  tags = {
    Environment = "dev"
    Project     = "Meu Projeto"
  }
}


