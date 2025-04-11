locals {

  application_tag = lookup(var.merged_tags, "application")
  environment_tag = lookup(var.merged_tags, "environment")
  cost_center_tag = lookup(var.merged_tags, "cost_center")

  common_prefix = "${local.application_tag}-${local.environment_tag}"

}

resource "aws_eks_cluster" "eks_cluster" {

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

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  url            = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


data "aws_eks_cluster" "cluster_metadata" {

  name = aws_eks_cluster.eks_cluster.name

}

resource "aws_security_group_rule" "eks_cluster_sg_rules" {

  for_each = { for idx, rule in var.eks_cluster_securitygroup_rules : idx => rule }

  security_group_id = data.aws_eks_cluster.cluster_metadata.vpc_config[0].cluster_security_group_id

  type        = each.value.type
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  description = each.value.description

}
