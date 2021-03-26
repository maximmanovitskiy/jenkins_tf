variable "region" {}
variable "main_vpc_cidr_block" {
  description = "CIDR block of the main VPC"
}
variable "pub_subnet_cidr_block" {
  description = "CIDR blocks for public NAT/LB subnets"
  type        = list(any)
}
variable "priv_subnet_cidr_block" {
  description = "List of cidr blocks for jenkins private subnets"
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
  description = "ELB Port for opened connections"
}
variable "lb_ssh_port" {
  type        = number
  description = "LB port for Jenkins ssh connection"
}
variable "access_ip" {
  type        = list(any)
  description = "IP addresses to access Jenkins SSH"
}
variable "AWS_DEFAULT_REGION" {}
variable "resource_owner" {
  description = "Value for the tag 'Owner'"
}
variable "jenkins_key" {
  description = "SSH key for Jenkins access"
}
variable "cluster_name" {
  description = "Name of the cluster to admin"
}
