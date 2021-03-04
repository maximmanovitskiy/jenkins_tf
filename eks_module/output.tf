output "eks_cluster_id" {
  value = aws_eks_cluster.eks.id
}
output "eks_cluster_status" {
  value = aws_eks_cluster.eks.status
}
