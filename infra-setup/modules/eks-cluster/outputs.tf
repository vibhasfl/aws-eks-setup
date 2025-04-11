output "cluster_name" {
  value       = aws_eks_cluster.k8_cluster.name
  description = "EKS cluster name"
}
