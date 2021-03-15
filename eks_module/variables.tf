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
