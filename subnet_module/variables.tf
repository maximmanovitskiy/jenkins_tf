variable "vpc_id" {
  description = "VPC ID for subnet(s)"
}
variable "subnet_cidr_block" {
  type        = list(any)
  description = "List of subnets CIDR blocks"
}
variable "map_public_ip" {
  description = "Map public ip on launch"
  default     = true
}
variable "availability_zones" {
  type        = any
  description = "AZ for subnet(s)"
}
variable "tags" {
  description = "Tags for subnet resource"
  type        = map(any)
}
