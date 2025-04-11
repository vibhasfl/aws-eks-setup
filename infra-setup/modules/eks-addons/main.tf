resource "aws_eks_addon" "eks_cluster_addons" {
  for_each = { for k, v in var.eks_addons : k => v if k != "vpc_cni" }

  cluster_name                = var.eks_cluster_name
  addon_name                  = each.key
  addon_version               = each.value.addon_version
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update

  depends_on = [aws_eks_addon.vpc_cni]

  service_account_role_arn = each.value.svc_role_arn != "" ? each.value.svc_role_arn : null

}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = var.eks_cluster_name
  addon_name                  = "vpc_cni"
  addon_version               = var.eks_addons["vpc_cni"].addon_version
  resolve_conflicts_on_create = var.eks_addons["vpc_cni"].resolve_conflicts_on_create
  resolve_conflicts_on_update = var.eks_addons["vpc_cni"].resolve_conflicts_on_update
}
