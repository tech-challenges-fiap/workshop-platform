data "tls_certificate" "cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_security_group" "cluster" {
  name        = "${var.name_prefix}-cluster"
  description = "Additional security group attached to the EKS control plane."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cluster"
  })
}

resource "aws_iam_role" "cluster" {
  name = "${var.name_prefix}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ])

  policy_arn = each.key
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
  }

  tags = merge(var.tags, {
    Name = var.cluster_name
  })

  depends_on = [aws_iam_role_policy_attachment.cluster]
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eks-oidc"
  })
}

resource "aws_iam_role" "node" {
  name = "${var.name_prefix}-eks-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.key
  role       = aws_iam_role.node.name
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  instance_types  = var.node_instance_types
  node_group_name = "${var.name_prefix}-default"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.node_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-default"
  })

  depends_on = [aws_iam_role_policy_attachment.node]
}

resource "aws_eks_addon" "core" {
  for_each = toset([
    "coredns",
    "eks-pod-identity-agent",
    "kube-proxy",
    "vpc-cni"
  ])

  addon_name                  = each.key
  cluster_name                = aws_eks_cluster.this.name
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.default]
}
