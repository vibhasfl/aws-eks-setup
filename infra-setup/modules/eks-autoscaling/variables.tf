variable "merged_tags" {
  type        = map(string)
  description = "merged tags"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "eks_cluster_arn" {
  type        = string
  description = "EKS cluster arn"
}

variable "eks_node_role_arn" {
  type        = string
  description = "Node role arn"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key arn to be used for encryption"
}
