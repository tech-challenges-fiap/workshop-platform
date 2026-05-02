output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Additional cluster security group identifier."
  value       = aws_security_group.cluster.id
}

output "workload_security_group_id" {
  description = "EKS primary security group identifier used by managed nodes and workload egress."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "EKS OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.cluster.arn
}
