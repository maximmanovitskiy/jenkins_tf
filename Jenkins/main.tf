terraform {
  backend "s3" {
    bucket         = "terraform-20210301092226465500000001"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "remote-state-locks"
    encrypt        = true
  }
}
provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_ami" "ubuntu_ami" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# ______________________________________________________________________________

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmp60+GGnRIZJ9pe1F/xo7QGH7qhm23gx8ZAhVBK9Z5ysd7yyeQjMel7ZwmVYym9JWueY2eWhfJBGdnP68c2+EnAjNmZ8fsx7N9mBRYfmKjEh+wMMajZikONGk62q4a9QgrTrZCybErmNPPLdsgHwLulJ23uMWnxpDG4XGUlqMr+E1RlAYddWcpyPRND1TsGH5cy3+91SHUtFmQssTnQrPTntmUMAuFyRyAvAx94Xh0JiZi/4S1FKXwC2WMMgOC4HTQvLrC6zPkYIm9izT6LqEmZu+PxXLU5uiD8ghWyUcQ873RY8Lh3m9aa8tNv0GpOaywvymkE4p4jWnhHbOv+K+U0YLV1lVqg8m4qpPammHKpOg8/43aRDB1xTBGlpVIjTZhi7kqCj7r0DQaPy9A4KizGA7EDINaXsM6u31q+adCEjSzUrycQJutVpKezPkebpZYoMRa+qRnjS5mBH/AiNSuCH+s59GFvglZF7MkW4Nh3nVoLdGDkq/CahY+Rr3rnU="
  tags = {
    Name         = "Jenkins_key"
    ResourceName = "Key_pair"
    Owner        = "Maxim Manovitskiy"
  }
}

resource "aws_security_group" "jenkins_group" {
  name   = "jenkins_group"
  vpc_id = module.vpc.id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_sg.id, aws_security_group.elb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name         = "Jenkins_Sec_Group"
    ResourceName = "Security_group"
    Owner        = "Maxim Manovitskiy"
  }
}

resource "aws_launch_configuration" "jenkins_LC" {
  name            = "Jenkins_LC"
  image_id        = data.aws_ami.ubuntu_ami.id #latest ubuntu ami
  instance_type   = var.instance_type
  key_name        = aws_key_pair.jenkins_key.id
  security_groups = [aws_security_group.jenkins_group.id]
  user_data       = data.template_file.init.rendered
}

resource "aws_autoscaling_group" "jenkins_autosc_group" {
  name                 = "Jenkins_autosc_group"
  launch_configuration = aws_launch_configuration.jenkins_LC.name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = module.elb_subnet.id
  load_balancers       = [aws_elb.jenkins-elb.id]
  target_group_arns    = [aws_lb_target_group.lb_target.arn]
  health_check_type    = "EC2"
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_efs_file_system.efs_jenkins_home, aws_efs_mount_target.jenkins_efs_mount_0,
  aws_efs_mount_target.jenkins_efs_mount_1, aws_efs_mount_target.jenkins_efs_mount_2]
  tags = [
    {
      key                 = "ResourceName"
      value               = "Auto-scaling group"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "Maxim Manovitskiy"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "Jenkins Master auto-scaling group"
      propagate_at_launch = true
    }
  ]
}

resource "aws_efs_file_system" "efs_jenkins_home" {
  creation_token = "efs_jenkins_home"
  encrypted      = true
  tags = {
    Name         = "Jenkins EFS"
    ResourceName = "EFS"
    Owner        = "Maxim Manovitskiy"
  }
}
/*
resource "aws_efs_mount_target" "jenkins_efs_mount_0" {
  file_system_id  = aws_efs_file_system.efs_jenkins_home.id
  subnet_id       = module.elb_subnet.id[0]
  security_groups = [aws_security_group.efs_sg.id]
}
resource "aws_efs_mount_target" "jenkins_efs_mount_1" {
  file_system_id  = aws_efs_file_system.efs_jenkins_home.id
  subnet_id       = module.elb_subnet.id[1]
  security_groups = [aws_security_group.efs_sg.id]
}
resource "aws_efs_mount_target" "jenkins_efs_mount_2" {
  file_system_id  = aws_efs_file_system.efs_jenkins_home.id
  subnet_id       = module.elb_subnet.id[2]
  security_groups = [aws_security_group.efs_sg.id]
}
*/
resource "aws_efs_mount_target" "jenkins_efs_mount" {
  file_system_id  = aws_efs_file_system.efs_jenkins_home.id
  count           = length(module.elb_subnet.id)
  subnet_id       = module.elb_subnet.id[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}
resource "aws_security_group" "efs_sg" {
  name   = "efs_sg"
  vpc_id = module.vpc.id
  ingress {
    security_groups = [aws_security_group.jenkins_group.id]
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
  }
  egress {
    security_groups = [aws_security_group.jenkins_group.id]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }
  tags = {
    Name         = "EFS_Jenkins_Sec_Group"
    ResourceName = "Security_group"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_ecr_repository" "ecr" {
  name                 = "ecr_images_from_jenkins"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name         = "ECR_images_from_jenkins"
    ResourceName = "ECR"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep only 10 images",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}
data "template_file" "init" {
  template = file("./jenkins.sh")
  vars = {
    efs_address           = aws_efs_file_system.efs_jenkins_home.dns_name
    AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION    = var.AWS_DEFAULT_REGION
  }
}
