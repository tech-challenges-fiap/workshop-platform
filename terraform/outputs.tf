output "name_prefix" {
  description = "Prefixo padrao para recursos de plataforma."
  value       = local.name_prefix
}

output "eks_cluster_name" {
  description = "Nome canonico de referencia para o cluster EKS."
  value       = local.eks_cluster_name
}

