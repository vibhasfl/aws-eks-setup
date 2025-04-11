variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

variable "environment_tag" {
  type        = string
  description = "Setup environment"
}

variable "application_name_tag" {
  type        = string
  description = "Application name"
}

variable "cost_center_tag" {
  type        = string
  description = "Cost center name"
}

variable "eks_cluster_version" {
  type        = string
  description = "eks cluster version"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets ids"
}

variable "enable_private_access" {
  type        = bool
  description = "Is cluster to be private"
  default     = true
}

variable "enable_public_access" {
  type        = bool
  description = "Is cluster to be public"
  default     = false
}

variable "eks_cluster_iam_policies" {
  type        = list(string)
  description = "List of IAM policies to be attached to eks cluster role"
  default     = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key arn to be used for encryption"
}

variable "eks_auth_mode" {
  type        = string
  description = "Authentication mode for eks cluster"
  default     = "API"
}

variable "eks_addons" {

  type = map(object({
    addon_version = string
  }))

  description = "Map of EKS addons"

  default = {
    "vpc_cni" = {
      addon_version               = "v1.19.3-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      svc_role_arn                = null
    },
    "kube_proxy" = {
      addon_version               = "v1.31.3-eksbuild.2"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      svc_role_arn                = null
    }
  }

}
