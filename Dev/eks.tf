module "eks" {
  source              = "../eks_module"
  name                = "nginx_eks"
  subnet_ids          = module.eks_subnets.id
  node_group_name     = "nginx_eks_group"
  node_subnet_ids     = module.eks_subnets.id
  desired_node_number = var.desired_node_number
  max_node_number     = var.max_node_number
  min_node_number     = var.min_node_number
  pub_access          = var.pub_access
  priv_access         = var.priv_access
}
