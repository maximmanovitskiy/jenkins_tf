variable "region" {
  description = "Region for AWS resources"
}
variable "eks_vpc_cidr_block" {
  description = "VPC Cidr for EKS cluster"
}
variable "eks_priv_subnet_cidr_block" {
  type        = list(any)
  description = "CIDR blocks for EKS subnets"
}
variable "nat_pub_subnet_cidr_block" {
  type        = list(any)
  description = "CIDR blocks for NAT subnets"
}
