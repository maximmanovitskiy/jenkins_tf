# Core VPC
/*
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
*/
module "vpc" {
  source         = "../vpc_module"
  vpc_cidr_block = var.main_vpc_cidr_block
  dns_hostnames  = true
  dns_support    = true
}
# Jenkins and NAT IG
resource "aws_internet_gateway" "gw" {
  vpc_id = module.vpc.id
  tags = {
    Name         = "Jenkins_IGW"
    ResourceName = "IGW"
    Owner        = "Maxim Manovitskiy"
  }
}
# Route everything to IG
resource "aws_route_table" "route_table" {
  vpc_id = module.vpc.id
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
  subnet_id      = element(module.elb_subnet.id, count.index)
  count          = length(var.elb_subnet_cidr_block)
  route_table_id = aws_route_table.route_table.id
}
module "elb_subnet" {
  source             = "../subnet_module"
  vpc_id             = module.vpc.id
  subnet_cidr_block  = var.elb_subnet_cidr_block
  availability_zones = data.aws_availability_zones.available.names
  map_public_ip      = true
}
/*
resource "aws_subnet" "elb_subnet" {
  vpc_id                  = module.vpc.id
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
*/
# ELB configuration ________________________________
resource "aws_elb" "jenkins-elb" {
  name            = "jenkins-elb"
  subnets         = module.elb_subnet.id
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
  subnets            = module.elb_subnet.id
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
  vpc_id   = module.vpc.id
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
  vpc_id = module.vpc.id

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
  vpc_id = module.vpc.id

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
