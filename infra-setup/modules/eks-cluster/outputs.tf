output "cluster_name" {
  value       = aws_eks_cluster.k8_cluster.name
  description = "EKS cluster name"
}

output "cluster_arn" {
  value       = aws_eks_cluster.k8_cluster.arn
  description = "EKS cluster name"
}
