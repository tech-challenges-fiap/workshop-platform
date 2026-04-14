locals {
  name_prefix      = "${var.project}-${var.repo}-${var.environment}"
  eks_cluster_name = "${local.name_prefix}-${var.resource_suffix}"
}

resource "terraform_data" "baseline" {
  input = {
    name_prefix      = local.name_prefix
    eks_cluster_name = local.eks_cluster_name
  }
}

