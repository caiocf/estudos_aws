# Definindo as variáveis para VPC e Subnets
variable "vpc_id" {
  description = "O ID da VPC onde o cluster EKS será criado"
  type        = string
  default     = "vpc-1234567890abcdef0"
}

variable "subnets" {
  description = "Lista de subnets para o cluster EKS"
  type        = list(string)
    default     = ["subnet-1234567890abcdef0", "subnet-abcdef1234567890"]
}