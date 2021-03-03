/*
module "eks" {
  source            = "./eks_module"
  name              = "nginx_eks"
  subnet_ids        = var.eks_priv_subnet_cidr_block
  availability_zone = data.aws_availability_zones.available.*.names
  vpc_cidr_block    = var.main_vpc_cidr_block
}
*/
