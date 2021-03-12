
# _____________________________________________________________
resource "aws_eks_cluster" "eks" {
  name     = var.name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.priv_access
    endpoint_public_access  = var.pub_access
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
  tags = {
    Name         = "EKS_nginx_cluster"
    ResourceName = "EKS_cluster"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_key_pair" "eks_node_key" {
  key_name   = "eks_node_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9tGkZrP7SItDRdzwkAv3OXkoPlZ20WAA+MVrqI4MZZNhjmfRldsRxZ/hm7hEnF4YWYRKXQEigWLnqEnQusgaTjg2pkfp2nXi4ak+Jmv+b9pzp/KskI1+eCzDW+87L4sFp+p0yExEsf3DPqb+QW0VmyuK/ishkckQkrks1ESf3bI8Z0YDjqPKnU5pt6O+IhdwOwGZVsHaFtQU/xr3hO0lmdR3G88zylD0ljzZoRczt0aJgzfIjM74rDIcXQb4RXMDIex24TC628jLkYqnGzsUd4vIZPnAZdhfUTO7DlXlZX3/3VCaEU80hL/FWcMpJnK5xCuryuRXArg1SSRJJ0HCwQCN/sKwmK/woJdw+pNI8KYTw10MDLaD9FEiGQ6jyDXJ2G97tWN1pHmqkiPnUguunwZ7Q/uVRdbkjb+1X/3jhNyJAHa9tL42qH8t7IwTZB4XktvJMtaWoaH9BxYgtFLSX86wsnZ+tDp9sIkS0L+3e25QIdcqiRHjEPE9K705hblrZV+8ySZXWi6wT2Dra+0jOfbLS4aMUiExyJwHugPwqgEjYVWm1MJPjwm5KaWobwQ3UrVnGazcP8EfMWxi0EtQ9USi3/90JceEddXo9t7xHu6r0CjTCcc87VE+GLqJwXWwObfFnyBs2ge1hidY+UIGtx2tGxYZeMfMCD4pk6TQUVQ=="
  tags = {
    Name         = "EKS_node_key"
    ResourceName = "Key_pair"
    Owner        = "Maxim Manovitskiy"
  }
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
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    Name         = "EKS_nginx_node_group"
    ResourceName = "EKS_node_group"
    Owner        = "Maxim Manovitskiy"
  }
}
