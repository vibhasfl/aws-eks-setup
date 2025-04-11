
locals {
  merged_tags = {
    application = var.application_name_tag
    environment = var.environment_tag
    cost_center = var.cost_center_tag
  }
}


module "eks_cluster" {
  source              = "./modules/eks-cluster"
  eks_cluster_version = var.eks_cluster_version
  kms_key_arn         = var.kms_key_arn
  subnet_ids          = var.subnet_ids
  merged_tags         = local.merged_tags
}

module "eks_cluster_nodes" {
  source           = "./modules/eks-nodegroup"
  eks_cluster_name = module.eks_cluster.cluster_name
  kms_key_arn      = var.kms_key_arn
  subnet_ids       = var.subnet_ids
  merged_tags      = local.merged_tags

}
