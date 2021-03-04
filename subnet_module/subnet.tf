resource "aws_subnet" "subnet" {
  vpc_id                  = var.vpc_id
  count                   = length(var.subnet_cidr_block)
  cidr_block              = element(var.subnet_cidr_block, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = var.map_public_ip
  tags = {
    Name         = "Subnet"
    ResourceName = "VPC_subnet"
    Owner        = "Maxim Manovitskiy"
  }
}
