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
# Jenkins and NAT IG
resource "aws_internet_gateway" "gw" {
  vpc_id = module.jenkins_vpc.id
  tags = {
    Name         = "Jenkins_IGW"
    ResourceName = "IGW"
    Owner        = var.resource_owner
  }
}
# Route everything to IG
resource "aws_route_table" "route_table" {
  vpc_id = module.jenkins_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name         = "ELB route table"
    ResourceName = "Route_table"
    Owner        = var.resource_owner
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
  vpc_id             = module.jenkins_vpc.id
  subnet_cidr_block  = var.elb_subnet_cidr_block
  availability_zones = data.aws_availability_zones.available.names
  map_public_ip      = true
  tags = {
    Name         = "ELB_subnet"
    ResourceName = "VPC_subnet"
    Owner        = var.resource_owner
  }
}

# ELB configuration ________________________________
resource "aws_elb" "jenkins-elb" {
  name            = "jenkins-elb"
  subnets         = module.elb_subnet.id
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
  subnets            = module.elb_subnet.id
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
