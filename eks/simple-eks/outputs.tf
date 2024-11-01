# Saída da URL do cluster EKS
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

# Saída do ARN do cluster
output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}