resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name         = "NAT elastic_ip"
    ResourceName = "EIP"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_route_table_association" "nat_pub_route" {
  subnet_id      = element(aws_subnet.nat_pub_subnet.*.id, count.index)
  count          = length(var.nat_pub_subnet_cidr_block)
  route_table_id = aws_route_table.route_table.id
}
resource "aws_subnet" "eks_priv_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  count             = length(var.eks_priv_subnet_cidr_block)
  cidr_block        = element(var.eks_priv_subnet_cidr_block, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name         = "EKS private subnet"
    ResourceName = "VPC_subnet"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_subnet" "nat_pub_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  count                   = length(var.nat_pub_subnet_cidr_block)
  cidr_block              = element(var.nat_pub_subnet_cidr_block, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name         = "NAT public subnet"
    ResourceName = "VPC_subnet"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_route_table" "nat_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name         = "NAT route table"
    ResourceName = "Route_table"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_route_table_association" "nat_priv_route" {
  subnet_id      = element(aws_subnet.eks_priv_subnet.*.id, count.index)
  count          = length(var.eks_priv_subnet_cidr_block)
  route_table_id = aws_route_table.nat_route_table.id
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.nat_pub_subnet.*.id
  tags = {
    Name         = "EKS_NAT_GW"
    ResourceName = "NAT_GW"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.nat_pub_subnet.*.id
  tags = {
    Name         = "EKS_NAT_GW"
    ResourceName = "NAT_GW"
    Owner        = "Maxim Manovitskiy"
  }
}
/*
resource "aws_eks_cluster" "nginx_eks" {
  name     = "nginx_eks"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id]
  }
  depends_on = [aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy]
}
resource "aws_iam_role" "example" {
  name = "eks-cluster-example"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example.name
}
*/
