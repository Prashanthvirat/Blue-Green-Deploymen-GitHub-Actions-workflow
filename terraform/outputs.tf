output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.strapi.name
}

output "task_definition_family" {
  description = "Task Definition Family"
  value       = aws_ecs_task_definition.strapi.family
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS"
  value       = aws_lb.main.dns_name
}

output "codedeploy_application_name" {
  description = "CodeDeploy Application Name"
  value       = aws_codedeploy_app.strapi.name
}

output "codedeploy_deployment_group" {
  description = "CodeDeploy Deployment Group"
  value       = aws_codedeploy_deployment_group.strapi_group.deployment_group_name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.strapi.arn
}

output "alb_listener_prod_arn" {
  value = aws_lb_listener.prod_listener.arn
}

output "alb_listener_test_arn" {
  value = aws_lb_listener.test_listener.arn
}