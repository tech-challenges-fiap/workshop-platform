locals {
  name_prefix      = "${var.project}-${var.repo}-${var.environment}"
  eks_cluster_name = "${local.name_prefix}-${var.resource_suffix}"
  namespaces       = ["stag", "prod"]

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project
    Repository  = "workshop-${var.repo}"
  }
}

data "aws_caller_identity" "current" {}

module "network" {
  source = "./modules/network"

  az_count           = var.az_count
  enable_nat_gateway = var.enable_nat_gateway
  name_prefix        = local.name_prefix
  tags               = local.tags
  vpc_cidr           = var.vpc_cidr
}

module "eks" {
  source = "./modules/eks"

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_name                    = local.eks_cluster_name
  cluster_version                 = var.cluster_version
  name_prefix                     = local.name_prefix
  node_desired_size               = var.node_desired_size
  node_instance_types             = var.node_instance_types
  node_max_size                   = var.node_max_size
  node_min_size                   = var.node_min_size
  node_subnet_ids                 = var.node_subnet_tier == "public" ? module.network.public_subnet_ids : module.network.private_subnet_ids
  private_subnet_ids              = module.network.private_subnet_ids
  public_subnet_ids               = module.network.public_subnet_ids
  tags                            = local.tags
  vpc_id                          = module.network.vpc_id
}

data "aws_eks_cluster" "platform" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "platform" {
  name = module.eks.cluster_name
}

resource "kubernetes_namespace_v1" "environment" {
  for_each = toset(local.namespaces)

  metadata {
    labels = {
      "app.kubernetes.io/managed-by" = "workshop-platform"
      "workshop.fiap.io/environment" = each.key
    }

    name = each.key
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx_chart_version

  set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
    }
  ]

  depends_on = [module.eks]
}

resource "helm_release" "datadog" {
  count = var.enable_datadog ? 1 : 0

  name             = "datadog"
  namespace        = "datadog"
  create_namespace = true
  repository       = "https://helm.datadoghq.com"
  chart            = "datadog"
  version          = var.datadog_chart_version

  set = [
    {
      name  = "datadog.logs.enabled"
      value = "true"
    },
    {
      name  = "datadog.site"
      value = "us5.datadoghq.com"
    },
    {
      name  = "datadog.logs.containerCollectAll"
      value = "true"
    },
    {
      name  = "datadog.apm.portEnabled"
      value = "true"
    },
    {
      name  = "datadog.processAgent.enabled"
      value = "true"
    },
    {
      name  = "datadog.otlp.receiver.protocols.grpc.enabled"
      value = "true"
    },
    {
      name  = "datadog.otlp.receiver.protocols.grpc.endpoint"
      value = "0.0.0.0:4317"
    },
    {
      name  = "datadog.otlp.receiver.protocols.grpc.useHostPort"
      value = "true"
    },
    {
      name  = "datadog.env[0].name"
      value = "DD_ENV"
    },
    {
      name  = "datadog.env[0].valueFrom.fieldRef.fieldPath"
      value = "metadata.namespace"
    },
    {
      name  = "datadog.clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "datadog.tags[0]"
      value = "project:workshop"
    }
  ]

  set_sensitive = [
    {
      name  = "datadog.apiKey"
      value = var.datadog_api_key
    }
  ]

  depends_on = [module.eks]
}

module "monitoring" {
  source = "./modules/monitoring"

  enable               = var.enable_datadog
  service_name         = "workshop-app"
  edge_service_name    = "workshop-edge"
  notification_targets = var.datadog_notification_targets
}

data "kubernetes_service_v1" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.ingress_nginx]
}

resource "aws_iam_role" "deploy" {
  name = "${local.name_prefix}-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "deploy_describe_cluster" {
  name = "${local.name_prefix}-describe-cluster"
  role = aws_iam_role.deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = module.eks.cluster_arn
      }
    ]
  })
}

resource "aws_eks_access_entry" "deploy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.deploy.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "deploy_namespace_edit" {
  for_each = toset(local.namespaces)

  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  principal_arn = aws_iam_role.deploy.arn

  access_scope {
    type       = "namespace"
    namespaces = [each.key]
  }

  depends_on = [
    aws_eks_access_entry.deploy,
    kubernetes_namespace_v1.environment
  ]
}
