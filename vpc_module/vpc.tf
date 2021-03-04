resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.dns_hostnames
  enable_dns_support   = var.dns_support
  tags = {
    Name         = "Main_VPC"
    ResourceName = "VPC"
    Owner        = "Maxim Manovitskiy"
  }
}
