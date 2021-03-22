# _____________________________________________________________
resource "aws_eks_cluster" "eks" {
  name     = var.name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.priv_access
    endpoint_public_access  = var.pub_access
    security_group_ids      = [aws_security_group.eks-sg.id]
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
  tags       = var.eks_cluster_tags
}
resource "aws_security_group" "eks-sg" {
  name   = "eks-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = var.sg_for_access
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.eks_sg_tags
}

resource "aws_key_pair" "eks_node_key" {
  key_name   = "eks_node_key"
  public_key = var.public_key
  tags       = var.ssh_key_tags
}

resource "aws_eks_node_group" "nginx_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = var.node_subnet_ids

  scaling_config {
    desired_size = var.desired_node_number
    max_size     = var.max_node_number
    min_size     = var.min_node_number
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.eks_node_key.id
  }

  depends_on = [aws_iam_role_policy_attachment.node_group_policy_attach]
  tags       = var.node_group_tags
}
