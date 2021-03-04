
# _____________________________________________________________
resource "aws_eks_cluster" "eks" {
  name     = var.name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = var.subnet_ids
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
  tags = {
    Name         = "EKS_nginx_cluster"
    ResourceName = "EKS_cluster"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {
    Name         = "EKS_cluster_iam_role"
    ResourceName = "IAM_role"
    Owner        = "Maxim Manovitskiy"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}
