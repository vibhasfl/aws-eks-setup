resource "aws_eks_addon" "eks_cluster_addons" {
  for_each = var.eks_addons

  cluster_name                = var.eks_cluster_name
  addon_name                  = each.key
  addon_version               = each.value.addon_version
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update

  service_account_role_arn = each.value.svc_role_arn != "" ? each.value.svc_role_arn : null
}
