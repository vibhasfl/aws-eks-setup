locals {

  application_tag = lookup(var.merged_tags, "application")
  environment_tag = lookup(var.merged_tags, "environment")
  cost_center_tag = lookup(var.merged_tags, "cost_center")

  common_prefix = "${local.application_tag}-${local.environment_tag}"

}

resource "aws_iam_role" "karpenter_ctrl_role" {
  name = "${local.common_prefix}-karpenter-ctrl-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession"]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

# Ref : https://karpenter.sh/docs/getting-started/migrating-from-cas/
resource "aws_iam_policy" "karpenter_ctrl_policy" {
  name        = "${local.common_prefix}-karpenter-ctrl-policy"
  description = "Policy for karpenter controller"
  policy = jsonencode({

    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect"   = "Allow",
        "Resource" = "*",
        "Action" = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts",
          "iam:GetInstanceProfile",
          "ssm:GetParameter",
          "iam:RemoveRoleFromInstanceProfile"
        ]
      },
      {
        "Effect"   = "Allow",
        "Action"   = ["iam:PassRole"],
        "Resource" = var.eks_node_role_arn
      },
      {
        "Sid" : "AllowCrossAcKMSAccess",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ],
        "Effect" : "Allow",
        "Resource" : var.kms_key_arn
      },
      {
        "Sid" : "AllowEksAccess",
        "Effect" : "Allow",
        "Action" : [
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster"
        ],
        "Resource" : var.eks_cluster_arn
      },
      {
        "Sid" : "AllowScopedInstanceProfileActions",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/kubernetes.io/cluster/${var.eks_cluster_name}" : "owned",
            "aws:ResourceTag/topology.kubernetes.io/region" : "ap-south-1"
          },
          "StringLike" : {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" : "*"
          }
        }
      },
      {
        "Sid" : "AllowScopedInstanceProfileTagActions",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "iam:TagInstanceProfile"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/kubernetes.io/cluster/${var.eks_cluster_name}" : "owned",
            "aws:ResourceTag/topology.kubernetes.io/region" : "ap-south-1",
            "aws:RequestTag/kubernetes.io/cluster/${var.eks_cluster_name}" : "owned",
            "aws:RequestTag/topology.kubernetes.io/region" : "ap-south-1"
          },
          "StringLike" : {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" : "*",
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" : "*"
          }
        }
      },
      {
        "Sid" : "AllowScopedInstanceProfileCreationActions",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "iam:CreateInstanceProfile"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/kubernetes.io/cluster/${var.eks_cluster_name}" : "owned",
            "aws:RequestTag/topology.kubernetes.io/region" : "ap-south-1"
          },
          "StringLike" : {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" : "*"
          }
        }
      },
      {
        "Action" : "ec2:TerminateInstances",
        "Condition" : {
          "StringLike" : {
            "ec2:ResourceTag/karpenter.sh/nodepool" : "*"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "ConditionalEC2Termination"
      },
    ]

  })

}

resource "aws_iam_policy_attachment" "karpenter_policy_attach" {
  name       = "karpenter-policy-attachment"
  roles      = [aws_iam_role.karpenter_ctrl_role.name]
  policy_arn = aws_iam_policy.karpenter_ctrl_policy.arn
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = var.eks_cluster_name
  namespace       = "karpenter"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter_ctrl_role.arn
}
