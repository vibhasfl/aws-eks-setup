output "cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
  description = "EKS cluster name"
}

output "cluster_arn" {
  value       = aws_eks_cluster.eks_cluster.arn
  description = "EKS cluster name"
}
