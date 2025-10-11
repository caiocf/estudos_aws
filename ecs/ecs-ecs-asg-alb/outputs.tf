output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = data.aws_ecr_repository.bia.repository_url
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.bia.endpoint
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.bia.dns_name
}

output "alb_url" {
  description = "Application Load Balancer URL"
  value       = "http://${aws_lb.bia.dns_name}"
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.bia.name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.bia.name
}
