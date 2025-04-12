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


# Create vpc-cni first
module "vpc_cni_addon" {
  source           = "./modules/eks-addons"
  eks_cluster_name = module.eks_cluster.cluster_name
  eks_addons = {
    vpc-cni = var.eks_addons["vpc-cni"]
  }
}

module "eks_cluster_nodes" {
  source           = "./modules/eks-nodegroup"
  eks_cluster_name = module.eks_cluster.cluster_name
  kms_key_arn      = var.kms_key_arn
  subnet_ids       = var.subnet_ids
  merged_tags      = local.merged_tags

  depends_on = [module.vpc_cni_addon]

}

module "other_eks_addons" {
  source           = "./modules/eks-addons"
  eks_cluster_name = module.eks_cluster.cluster_name
  eks_addons = {
    for k, v in var.eks_addons : k => v if k != "vpc-cni"
  }

  depends_on = [module.eks_cluster_nodes]
}

module "eks_access" {
  source           = "./modules/eks-access"
  eks_cluster_name = module.eks_cluster.cluster_name
  access_entries = concat(var.access_entries, [{
    principal_arn = module.eks_jump_server.jump_server_role
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  }])
}


module "eks_jump_server" {
  source      = "./modules/eks-jump-host"
  merged_tags = local.merged_tags
  subnet_id   = var.subnet_ids[0]
  vpc_id      = var.vpc_id
  depends_on  = [module.eks_cluster]
}
