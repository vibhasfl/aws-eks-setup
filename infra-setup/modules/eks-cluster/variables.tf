variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

variable "merged_tags" {
  type        = map(string)
  description = "merged tags"
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

variable "eks_cluster_securitygroup_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))

  description = "SG rules to attach to eks cluster"
  default     = []

}
