/*
resource "aws_lb" "nginx_alb" {
  name               = "nginx_alb"
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
*/
