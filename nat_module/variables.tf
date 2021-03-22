variable "vpc_id" {
  description = "ID of VPC for the network"
}
variable "gw_tags" {
  description = "Tags for Internet GW resource"
}
variable "ig_route_table_tags" {
  description = ""
}
variable "pub_subnet_cidr_block" {
  description = "CIDR blocks for public NAT subnets"
  type        = list(any)
}
variable "availability_zones" {
  description = "List of AZ to put subnets in`"
}
variable "pub_subnet_tags" {
  description = "Tags for public NAT subnets"
}
variable "priv_subnet_cidr_block" {
  description = "CIDR blocks for private subnets"
  type        = list(any)
}
variable "priv_subnet_tags" {
  description = "Tags for private subnets"
}
variable "nat_eip_tags" {
  description = "Tags for elastic IP resource"
}

variable "nat_table_tags" {
  description = "Tags for route table 'private subnets to NAT'"
}
variable "nat_gw_tags" {
  description = "Tags for NAT GW resource"
}
