resource "aws_eip" "nat_eip" {
  vpc        = true
  count      = length(module.jenkins_subnets.id)
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name         = "NAT elastic_ips"
    ResourceName = "EIP"
    Owner        = var.resource_owner
  }
}
resource "aws_route_table" "nat_route_table" {
  vpc_id = module.jenkins_vpc.id
  count  = length(module.jenkins_subnets.id)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.*.id[count.index]
  }
  tags = {
    Name         = "Jenkins route table"
    ResourceName = "Route_table"
    Owner        = var.resource_owner
  }
}
resource "aws_route_table_association" "nat_priv_route" {
  count          = length(module.jenkins_subnets.id)
  subnet_id      = module.jenkins_subnets.id[count.index]
  route_table_id = aws_route_table.nat_route_table.*.id[count.index]
}
resource "aws_nat_gateway" "nat_gw" {
  count         = length(module.jenkins_subnets.id)
  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id     = module.elb_subnet.id[count.index]
  depends_on    = [aws_internet_gateway.gw]
  tags = {
    Name         = "Jenkins_NAT_GW"
    ResourceName = "NAT_GW"
    Owner        = var.resource_owner
  }
}
