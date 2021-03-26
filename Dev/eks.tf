
module "eks" {
  source              = "../eks_module"
  name                = var.eks_cluster_name
  subnet_ids          = module.nat_network.priv_subnet_id
  node_group_name     = "nginx_eks_group"
  node_subnet_ids     = module.nat_network.priv_subnet_id
  desired_node_number = var.desired_node_number
  max_node_number     = var.max_node_number
  min_node_number     = var.min_node_number
  pub_access          = var.pub_access
  priv_access         = var.priv_access
  sg_for_access       = [aws_security_group.bastion_sg.id]
  vpc_id              = module.vpc.id
  public_key          = var.public_key
  working_dir         = var.working_dir
  command             = var.command
  eks_cluster_tags = {
    Name         = "EKS_nginx_cluster"
    ResourceName = "EKS_cluster"
    Owner        = var.resource_owner
  }
  eks_sg_tags = {
    Name         = "Cluster_Sec_Group"
    ResourceName = "Security_group"
    Owner        = var.resource_owner
  }
  node_group_tags = {
    Name         = "EKS_nginx_node_group"
    ResourceName = "EKS_node_group"
    Owner        = var.resource_owner
  }
  ssh_key_tags = {
    Name         = "EKS_node_key"
    ResourceName = "Key_pair"
    Owner        = var.resource_owner
  }
}
