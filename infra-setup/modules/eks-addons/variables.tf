variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}


variable "eks_addons" {

  type = map(object({
    addon_version               = string
    resolve_conflicts_on_create = string
    resolve_conflicts_on_update = string
    svc_role_arn                = string
  }))

  description = "Map of EKS addons"

}
