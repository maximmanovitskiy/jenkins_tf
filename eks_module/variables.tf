variable "name" {
  description = "Name of the EKS cluster"
}
variable "subnet_ids" {
  description = "Subnet Ids for EKS cluster"
}
variable "node_group_name" {
  description = "The name of the node group"
}
variable "node_subnet_ids" {
  description = "Subnet ids for node group"
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
  default     = true
  description = "whether or not EKS public API endpoint is enabled"
}
variable "priv_access" {
  default     = false
  description = "whether or not EKS private API endpoint is enabled"
}
variable "sg_for_access" {
  type        = list(any)
  description = "Security groups to access cluster"
}
variable "vpc_id" {
  description = "ID of the VPC"
}
variable "eks_cluster_tags" {
  description = "Tags of the EKS cluster resource"
}
variable "eks_sg_tags" {
  description = "Tags of the EKS cluster security group resource"
}
variable "node_group_tags" {
  description = "Tags of the EKS cluster node group resource"
}
variable "ssh_key_tags" {
  description = "Tags for ssh key for node group"
}
variable "public_key" {
  description = "Public ssh key for node group access"
}
variable "nodes_policy_arn" {
  type        = list(any)
  description = "ARN of policies to add to the cluster node group"
  default     = []
}
variable "command" {
  description = "Command to execute locally once node group is created"
  default     = "sleep 0"
}
variable "working_dir" {
  description = "Working dir to execute the local command from (node grp)"
  default     = "./"
}
