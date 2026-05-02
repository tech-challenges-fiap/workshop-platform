output "name_prefix" {
  description = "Default prefix for platform resources."
  value       = local.name_prefix
}

output "cluster_name" {
  description = "EKS cluster name consumed by workshop-app deployments."
  value       = module.eks.cluster_name
}

output "cluster_region" {
  description = "AWS region where the EKS cluster runs."
  value       = var.aws_region
}

output "deploy_role_arn" {
  description = "IAM role ARN allowed to deploy Kubernetes resources into stag and prod namespaces."
  value       = aws_iam_role.deploy.arn
}

output "ingress_hostname_stag" {
  description = "Public ingress load balancer hostname used by the stag namespace."
  value       = try(data.kubernetes_service_v1.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "ingress_hostname_prod" {
  description = "Public ingress load balancer hostname used by the prod namespace."
  value       = try(data.kubernetes_service_v1.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "namespace_stag" {
  description = "Kubernetes namespace for staging workloads."
  value       = kubernetes_namespace_v1.environment["stag"].metadata[0].name
}

output "namespace_prod" {
  description = "Kubernetes namespace for production workloads."
  value       = kubernetes_namespace_v1.environment["prod"].metadata[0].name
}

output "vpc_id" {
  description = "Platform VPC identifier."
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet identifiers used by EKS nodes and workload connectivity."
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet identifiers used by internet-facing load balancers."
  value       = module.network.public_subnet_ids
}

output "workload_security_group_id" {
  description = "EKS primary security group to allow platform workload connectivity from dependent stacks."
  value       = module.eks.workload_security_group_id
}
