variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

variable "merged_tags" {
  type        = map(string)
  description = "merged tags"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets ids"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key arn to be used for encryption"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "desired_size" {
  type        = number
  description = "Desired number of nodes"
  default     = 2
}

variable "min_size" {
  type        = number
  description = "Min number of nodes"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Max number of nodes"
  default     = 3
}

variable "disk_size" {
  type        = number
  description = "/xvdb disk size"
  default     = 10
}

variable "instance_type" {
  type        = string
  description = "EKS cluster Instance types"
  default     = "t3.medium"
}

variable "node_policies" {
  type        = list(string)
  description = "IAM policy ARNs to attach to the node role"
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}
