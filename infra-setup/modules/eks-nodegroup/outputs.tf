output "eks_node_role_arn" {
  value       = aws_iam_role.eks_cluster_node_role.arn
  description = "EKS node role ARN"
}
