variable "vpc_cidr_block" {
  description = "VPC CIDR block"
}
variable "dns_hostnames" {
  description = "Enable/disable dns_hostnames"
  default     = true
}
variable "dns_support" {
  description = "Enable/disable dns_support"
  default     = true
}
variable "tags" {
  description = "Tags mapping for VPC resource"
  type        = map(any)
}
