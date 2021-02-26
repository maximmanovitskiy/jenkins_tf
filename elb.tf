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
## Security Group for ELB

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
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      #cidr_blocks = var.access_ip
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
