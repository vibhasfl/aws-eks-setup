
locals {
  merged_tags = {
    application_tag = var.application_name_tag
    environment_tag = var.environment_tag
    cost_center_tag = var.cost_center_tag
  }
}


module "eks_cluster" {
  source              = "./modules/eks-cluster"
  eks_cluster_version = var.eks_cluster_version
  kms_key_arn         = var.kms_key_arn
  subnet_ids          = var.subnet_ids
  merged_tags         = local.merged_tags
}
