resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id
  tags   = var.gw_tags
}
# Route everything to IG
resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = var.ig_route_table_tags
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = var.vpc_id
  count                   = length(var.pub_subnet_cidr_block)
  cidr_block              = var.pub_subnet_cidr_block[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = var.pub_subnet_tags
}
resource "aws_subnet" "private_subnet" {
  vpc_id                  = var.vpc_id
  count                   = length(var.priv_subnet_cidr_block)
  cidr_block              = var.priv_subnet_cidr_block[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags                    = var.priv_subnet_tags
}
# Route public subnets to routing tables -> IG
resource "aws_route_table_association" "table" {
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  count          = length(var.pub_subnet_cidr_block)
  route_table_id = aws_route_table.route_table.id
}
resource "aws_eip" "nat_eip" {
  vpc        = true
  count      = length(aws_subnet.private_subnet.*.id)
  depends_on = [aws_internet_gateway.gw]
  tags       = var.nat_eip_tags
}
resource "aws_route_table" "nat_route_table" {
  vpc_id = var.vpc_id
  count  = length(aws_subnet.private_subnet.*.id)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.*.id[count.index]
  }
  tags = var.nat_table_tags
}
resource "aws_route_table_association" "nat_priv_route" {
  count          = length(aws_subnet.private_subnet.*.id)
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.nat_route_table.*.id[count.index]
}
resource "aws_nat_gateway" "nat_gw" {
  count         = length(aws_subnet.private_subnet.*.id)
  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id     = aws_subnet.public_subnet.*.id[count.index]
  depends_on    = [aws_internet_gateway.gw]
  tags          = var.nat_gw_tags
}
