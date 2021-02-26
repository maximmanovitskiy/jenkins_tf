variable "region" {
  default = "us-east-1"
}
variable "main_vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "elb_subnet_cidr_block" {
  type    = list(any)
  default = ["10.0.50.0/24", "10.0.51.0/24", "10.0.52.0/24"]
}
variable "instance_type" {
  default = "t2.micro"
}
variable "alb_ports" {
  type    = list(any)
  default = ["80"]
}
variable "elb_ports" {
  type    = list(any)
  default = ["2222"]
}
variable "access_ip" {
  type    = list(any)
  default = [""]
}
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "AWS_DEFAULT_REGION" {}

variable "eks_priv_subnet_cidr_block" {
  type    = list(any)
  default = ["10.0.100.0/24", "10.0.101.0/24"]
}
variable "nat_pub_subnet_cidr_block" {
  type    = list(any)
  default = ["10.0.150.0/24", "10.0.151.0/24"]
}
