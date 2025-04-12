locals {

  application_tag = lookup(var.merged_tags, "application")
  environment_tag = lookup(var.merged_tags, "environment")
  cost_center_tag = lookup(var.merged_tags, "cost_center")

  common_prefix = "${local.application_tag}-${local.environment_tag}"

}

data "aws_launch_template" "eks_node_group_lt" {
  id = aws_launch_template.eks_node_group_lt.id
}

resource "aws_eks_node_group" "eks_node_group" {

  cluster_name    = var.eks_cluster_name
  node_role_arn   = aws_iam_role.eks_cluster_node_role.arn
  subnet_ids      = var.subnet_ids
  node_group_name = "${local.common_prefix}-eks-ng"

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  ami_type = "BOTTLEROCKET_x86_64"

  launch_template {
    id      = aws_launch_template.eks_node_group_lt.id
    version = data.aws_launch_template.eks_node_group_lt.latest_version
  }

  depends_on = [aws_launch_template.eks_node_group_lt]

}



resource "aws_launch_template" "eks_node_group_lt" {
  name          = "${local.common_prefix}-eks-lt"
  instance_type = var.instance_type
  description   = "LT for EKS cluster Node group"

  block_device_mappings {
    device_name = "/dev/xvdb"
    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp3"
      kms_key_id            = var.kms_key_arn
      delete_on_termination = true
      encrypted             = true
    }
  }

  dynamic "tag_specifications" {

    for_each = ["instance", "volume", "network-interface"]

    content {
      resource_type = tag_specifications.value
      tags = merge(var.merged_tags, {
        "Name" = "${local.common_prefix}-ng"
      })

    }
  }

  tags = merge(var.merged_tags, {
    "Name" = "${local.common_prefix}-eks-lt"
  })

}


resource "aws_iam_role" "eks_cluster_node_role" {

  name = "${local.common_prefix}-cluster-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession"],
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_role_policy_attachment" {

  for_each = toset(var.node_policies)

  role = aws_iam_role.eks_cluster_node_role.name

  policy_arn = each.value

}
