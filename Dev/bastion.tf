module "bast_subnet" {
  source = "../subnet_module"

  vpc_id             = module.vpc.id
  subnet_cidr_block  = var.bastion_cidr_block
  availability_zones = data.aws_availability_zones.available.names
}
resource "aws_route_table_association" "bast_pub_route" {
  subnet_id      = module.bast_subnet.id[count.index]
  count          = length(var.bastion_cidr_block)
  route_table_id = aws_route_table.route_table_eks.id
}
