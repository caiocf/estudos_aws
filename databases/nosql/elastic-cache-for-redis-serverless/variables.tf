
variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"
  validation {
    condition     = length(var.region) > 0
    error_message = "Região AWS inválida. A região deve ser uma string não vazia"

  }
}

variable "cluster_id" {
  default = "meu-cluster"
  type = string
  description = "name of the cluster redis"
}

variable "replication_group_id" {
  description = "The name of the ElastiCache replication group."
  default     = "app-redis-cluster"
  type        = string
}

variable "namespace" {
  description = "Default namespace"
  default = ""
}

variable "node_groups" {
  description = "Number of nodes groups to create in the cluster"
  default     = 3
}