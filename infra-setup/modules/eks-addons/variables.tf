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

  default = {
    "vpc_cni" = {
      addon_version               = "v1.19.3-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      svc_role_arn                = null
    },
    "kube_proxy" = {
      addon_version               = "v1.31.3-eksbuild.2"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      svc_role_arn                = null
    }
  }

}
