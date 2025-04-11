locals {

  application_tag = lookup(var.merged_tags, "application")
  environment_tag = lookup(var.merged_tags, "environment")
  cost_center_tag = lookup(var.merged_tags, "cost_center")

  common_prefix = "${local.application_tag}-${local.environment_tag}"

}

resource "aws_eks_cluster" "k8_cluster" {

  name = local.common_prefix

  version = var.eks_cluster_version

  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.enable_private_access
    endpoint_public_access  = var.enable_public_access
  }

  access_config {
    authentication_mode = var.eks_auth_mode
  }

  enabled_cluster_log_types = []

  bootstrap_self_managed_addons = false

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_arn
    }
  }

}


resource "aws_iam_role" "eks_cluster_role" {

  name = "${local.common_prefix}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession"],
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachment" {

  for_each = toset(var.eks_cluster_iam_policies)

  role = aws_iam_role.eks_cluster_role.arn

  policy_arn = each.value

}
