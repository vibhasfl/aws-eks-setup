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

module "eks_cluster_addons" {
  source           = "./modules/eks-addons"
  eks_cluster_name = module.eks_cluster.cluster_name
  eks_addons       = var.eks_addons
}

module "eks_access" {
  source           = "./modules/eks-access"
  eks_cluster_name = module.eks_cluster.cluster_name
  access_entries   = var.access_entries
}


module "eks_jump_server" {
  source      = "./modules/eks-jump-host"
  merged_tags = local.merged_tags
  subnet_id   = var.subnet_ids[0]
  vpc_id      = var.vpc_id
  depends_on  = [module.eks_cluster]
}
