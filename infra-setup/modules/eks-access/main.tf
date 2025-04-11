resource "aws_eks_access_entry" "eks_access_entries" {
  for_each = { for idx, entry in var.access_entries : idx => entry }

  cluster_name  = var.eks_cluster_name
  principal_arn = each.value.principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_access_entries_policy" {
  for_each = { for idx, entry in var.access_entries : idx => entry }

  cluster_name  = var.eks_cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn
  access_scope {
    type = "cluster"
  }
}
