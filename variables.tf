variable "region" {}
variable "main_vpc_cidr_block" {
  description = "CIDR block of the main VPC"
}
variable "elb_subnet_cidr_block" {
  type        = list(any)
  description = "CIDR blocks for LBs for jenkins"
}
variable "instance_type" {
  description = "Type of the instance for autoscaling"
}
variable "alb_ports" {
  type        = list(any)
  description = "ALB opened ports"
}
variable "elb_ports" {
  type        = list(any)
  description = "ELB Port for SSH connection"
}
variable "access_ip" {
  type        = list(any)
  description = "IP addresses to access Jenkins SSH"
}
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "AWS_DEFAULT_REGION" {}

variable "eks_priv_subnet_cidr_block" {
  type        = list(any)
  description = "CIDR blocks for EKS subnets"
}
variable "nat_pub_subnet_cidr_block" {
  type        = list(any)
  description = "CIDR blocks for NAT subnets"
}
