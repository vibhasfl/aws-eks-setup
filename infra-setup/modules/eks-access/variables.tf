variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}


variable "access_entries" {
  description = "List of access entries with principal ARN and policy ARN"
  type = list(object({
    principal_arn = string
    policy_arn    = string
  }))
}
