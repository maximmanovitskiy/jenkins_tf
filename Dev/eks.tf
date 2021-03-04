module "eks" {
  source     = "../eks_module"
  name       = "nginx_eks"
  subnet_ids = module.eks_subnets.id
}
