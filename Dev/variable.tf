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
variable "vpn_cidr" {
  description = "CIDR block for client IP address"
}
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
}
variable "desired_node_number" {
  description = "Desired number of the nodes"
}
variable "max_node_number" {
  description = "Maximum number of the nodes"
}
variable "min_node_number" {
  description = "Minimum number of the nodes"
}
variable "pub_access" {
  description = "whether or not EKS public API endpoint is enabled"
}
variable "priv_access" {
  description = "whether or not EKS private API endpoint is enabled"
}
variable "vpn_access_cidr" {
  type        = list(any)
  description = "CIDR block for VPN access"
}
variable "vpn_auth_grp_target" {
  description = "Target group for VPN authorization"
}
variable "bastion_cidr_block" {
  description = "CIDR block for bastion subnet"
}
variable "bast_ssh_port" {
  description = "SSH port for bastion access"
}
variable "bast_knock_port1" {
  description = "Port for the first port knock"
}
variable "bast_knock_port2" {
  description = "Port for the second port knock"
}
variable "bast_knock_port3" {
  description = "Port for the third port knock"
}
variable "bastion_acc_ip" {
  type        = list(any)
  description = "CIDR blocks for IP addresses to access bastion"
}
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "AWS_DEFAULT_REGION" {}
