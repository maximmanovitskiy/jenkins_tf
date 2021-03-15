module "vpc" {
  source         = "../vpc_module"
  vpc_cidr_block = var.eks_vpc_cidr_block
  dns_hostnames  = true
  dns_support    = true
}
module "nat_subnets" {
  source             = "../subnet_module"
  vpc_id             = module.vpc.id
  subnet_cidr_block  = var.nat_pub_subnet_cidr_block
  availability_zones = data.aws_availability_zones.available.names
  map_public_ip      = true
}
module "eks_subnets" {
  source             = "../subnet_module"
  vpc_id             = module.vpc.id
  subnet_cidr_block  = var.eks_priv_subnet_cidr_block
  availability_zones = data.aws_availability_zones.available.names
  map_public_ip      = true
}
resource "aws_internet_gateway" "gw_eks" {
  vpc_id = module.vpc.id
  tags = {
    Name         = "Jenkins_IGW"
    ResourceName = "IGW"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_route_table" "route_table_eks" {
  vpc_id = module.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_eks.id
  }
  tags = {
    Name         = "NAT-IG route table"
    ResourceName = "Route_table"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_eip" "nat_eip1" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw_eks]
  tags = {
    Name         = "NAT first elastic_ip"
    ResourceName = "EIP"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_eip" "nat_eip2" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw_eks]
  tags = {
    Name         = "NAT second elastic_ip"
    ResourceName = "EIP"
    Owner        = "Maxim Manovitskiy"
  }
}
# Route NAT subnets to IG
resource "aws_route_table_association" "nat_pub_route" {
  subnet_id      = element(module.nat_subnets.id, count.index)
  count          = length(var.nat_pub_subnet_cidr_block)
  route_table_id = aws_route_table.route_table_eks.id
}
# Table to route first private subnet to NAT
resource "aws_route_table" "nat_route_table1" {
  vpc_id = module.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }
  tags = {
    Name         = "First NAT route table"
    ResourceName = "Route_table"
    Owner        = "Maxim Manovitskiy"
  }
}
# Table to route second private subnet to NAT
resource "aws_route_table" "nat_route_table2" {
  vpc_id = module.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }
  tags = {
    Name         = "Second NAT route table"
    ResourceName = "Route_table"
    Owner        = "Maxim Manovitskiy"
  }
}
# Link first private subnet with route to NAT
resource "aws_route_table_association" "nat_priv_route1" {
  subnet_id      = module.eks_subnets.id[0]
  route_table_id = aws_route_table.nat_route_table1.id
}
# Link second private subnet with route to NAT
resource "aws_route_table_association" "nat_priv_route2" {
  subnet_id      = module.eks_subnets.id[1]
  route_table_id = aws_route_table.nat_route_table2.id
}
# First NAT gateway
resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = module.nat_subnets.id[0]
  depends_on    = [aws_internet_gateway.gw_eks]
  tags = {
    Name         = "First_EKS_NAT_GW"
    ResourceName = "NAT_GW"
    Owner        = "Maxim Manovitskiy"
  }
}
# Second NAT gateway
resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = module.nat_subnets.id[1]
  depends_on    = [aws_internet_gateway.gw_eks]
  tags = {
    Name         = "Second_EKS_NAT_GW"
    ResourceName = "NAT_GW"
    Owner        = "Maxim Manovitskiy"
  }
}
