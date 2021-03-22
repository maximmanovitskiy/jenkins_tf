# Core VPC

module "jenkins_vpc" {
  source         = "../vpc_module"
  vpc_cidr_block = var.main_vpc_cidr_block
  dns_hostnames  = true
  dns_support    = true
  tags = {
    Name         = "Jenkins_VPC"
    ResourceName = "VPC"
    Owner        = var.resource_owner
  }
}
module "nat_network" {
  source                 = "../nat_module"
  vpc_id                 = module.jenkins_vpc.id
  pub_subnet_cidr_block  = var.pub_subnet_cidr_block
  availability_zones     = data.aws_availability_zones.available.names
  priv_subnet_cidr_block = var.priv_subnet_cidr_block
  gw_tags = {
    Name         = "Jenkins_IGW"
    ResourceName = "IGW"
    Owner        = var.resource_owner
  }
  ig_route_table_tags = {
    Name         = "ELB route table"
    ResourceName = "Route_table"
    Owner        = var.resource_owner
  }
  pub_subnet_tags = {
    Name         = "Jenkins_pub_subnets"
    ResourceName = "VPC_subnet"
    Owner        = var.resource_owner
  }
  priv_subnet_tags = {
    Name         = "Jenkins_priv_subnet"
    ResourceName = "VPC_subnet"
    Owner        = var.resource_owner
  }
  nat_eip_tags = {
    Name         = "NAT elastic_ips"
    ResourceName = "EIP"
    Owner        = var.resource_owner
  }
  nat_table_tags = {
    Name         = "Jenkins route table"
    ResourceName = "Route_table"
    Owner        = var.resource_owner
  }
  nat_gw_tags = {
    Name         = "Jenkins_NAT_GW"
    ResourceName = "NAT_GW"
    Owner        = var.resource_owner
  }
}
#_____________________________________________________________________________
# ELB configuration ________________________________
resource "aws_elb" "jenkins-elb" {
  name            = "jenkins-elb"
  subnets         = module.nat_network.pub_subnet_id
  security_groups = [aws_security_group.elb_sg.id]
  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = var.lb_ssh_port
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
    Owner        = var.resource_owner
  }
}

resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-alb"
  load_balancer_type = "application"
  subnets            = module.nat_network.pub_subnet_id
  security_groups    = [aws_security_group.alb_sg.id]
  tags = {
    Name         = "Jenkins_alb"
    ResourceName = "App_load_balancer"
    Owner        = var.resource_owner
  }
}
resource "aws_lb_target_group" "lb_target" {
  name     = "lb-target-jenkins"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.jenkins_vpc.id
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
  vpc_id = module.jenkins_vpc.id

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
    Owner        = var.resource_owner
  }
}
resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = module.jenkins_vpc.id

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
    Owner        = var.resource_owner
  }
}
