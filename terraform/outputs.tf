output "name_prefix" {
  description = "Default prefix for platform resources."
  value       = local.name_prefix
}

output "eks_cluster_name" {
  description = "Canonical reference name for the EKS cluster."
  value       = local.eks_cluster_name
}
