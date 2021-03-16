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
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "AWS_DEFAULT_REGION" {}
variable "resource_owner" {
  description = "Value for the tag 'Owner'"
}
variable "jenkins_key" {
  description = "SSH key for Jenkins access"
}
