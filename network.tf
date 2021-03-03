# Core VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.main_vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name         = "Main_VPC"
    ResourceName = "VPC"
    Owner        = "Maxim Manovitskiy"
  }
}
# Jenkins and NAT IG
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name         = "Jenkins_IGW"
    ResourceName = "IGW"
    Owner        = "Maxim Manovitskiy"
  }
}
# Route everything to IG
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name         = "ELB route table"
    ResourceName = "Route_table"
    Owner        = "Maxim Manovitskiy"
  }
}
# Route ELB subnets to rauting tables -> IG
resource "aws_route_table_association" "table" {
  subnet_id      = element(aws_subnet.elb_subnet.*.id, count.index)
  count          = length(var.elb_subnet_cidr_block)
  route_table_id = aws_route_table.route_table.id
}

resource "aws_subnet" "elb_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  count                   = length(var.elb_subnet_cidr_block)
  cidr_block              = element(var.elb_subnet_cidr_block, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name         = "ELB subnet"
    ResourceName = "VPC_subnet"
    Owner        = "Maxim Manovitskiy"
  }
}

# ELB configuration ________________________________
resource "aws_elb" "jenkins-elb" {
  name            = "jenkins-elb"
  subnets         = aws_subnet.elb_subnet.*.id
  security_groups = [aws_security_group.elb_sg.id]
  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 2222
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 30
  }
  tags = {
    Name         = "Jenkins-elb"
    ResourceName = "ELB"
    Owner        = "Maxim Manovitskiy"
  }
}

resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.elb_subnet.*.id
  security_groups    = [aws_security_group.alb_sg.id]
  tags = {
    Name         = "Jenkins_alb"
    ResourceName = "App_load_balancer"
    Owner        = "Maksym Manovytskyi"
  }
}
resource "aws_lb_target_group" "lb_target" {
  name     = "lb-target-jenkins"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}
resource "aws_lb_listener" "jenkins_alb_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target.arn
  }
}

# Security Group for ELB
resource "aws_security_group" "elb_sg" {
  name   = "elb_sg"
  vpc_id = aws_vpc.main_vpc.id

  dynamic "ingress" {
    for_each = var.elb_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.access_ip
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name         = "Jenkins-elb-sg"
    ResourceName = "Security_group"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = aws_vpc.main_vpc.id

  dynamic "ingress" {
    for_each = var.alb_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name         = "Jenkins-alb-sg"
    ResourceName = "Security_group"
    Owner        = "Maxim Manovitskiy"
  }
}

# EKS network___________________________________________________
# EIP for 2 NAT gateways
resource "aws_eip" "nat_eip1" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name         = "NAT first elastic_ip"
    ResourceName = "EIP"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_eip" "nat_eip2" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name         = "NAT second elastic_ip"
    ResourceName = "EIP"
    Owner        = "Maxim Manovitskiy"
  }
}
# Route NAT subnets to IG
resource "aws_route_table_association" "nat_pub_route" {
  subnet_id      = element(aws_subnet.nat_pub_subnet.*.id, count.index)
  count          = length(var.nat_pub_subnet_cidr_block)
  route_table_id = aws_route_table.route_table.id
}
# EKS private subnet

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

# NAT public subnets
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
# Table to route first private subnet to NAT
resource "aws_route_table" "nat_route_table1" {
  vpc_id = aws_vpc.main_vpc.id
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
  vpc_id = aws_vpc.main_vpc.id
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
  subnet_id = aws_subnet.eks_priv_subnet.*.id[0]
  # subnet_id      = module.eks.subnet1_id
  route_table_id = aws_route_table.nat_route_table1.id
}
# Link second private subnet with route to NAT
resource "aws_route_table_association" "nat_priv_route2" {
  subnet_id = aws_subnet.eks_priv_subnet.*.id[1]
  # subnet_id      = module.eks.subnet2_id
  route_table_id = aws_route_table.nat_route_table2.id
}
# First NAT gateway
resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.nat_pub_subnet.*.id[0]
  depends_on    = [aws_internet_gateway.gw]
  tags = {
    Name         = "First_EKS_NAT_GW"
    ResourceName = "NAT_GW"
    Owner        = "Maxim Manovitskiy"
  }
}
# Second NAT gateway
resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.nat_pub_subnet.*.id[1]
  depends_on    = [aws_internet_gateway.gw]
  tags = {
    Name         = "Second_EKS_NAT_GW"
    ResourceName = "NAT_GW"
    Owner        = "Maxim Manovitskiy"
  }
}
