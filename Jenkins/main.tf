terraform {
  backend "s3" {
    bucket         = "terraform-20210301092226465500000001"
    key            = "CI-CD/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "jenkins"
    encrypt        = true
  }
}
provider "aws" {
  region = var.region
}
data "aws_caller_identity" "current" {}
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
  public_key = var.jenkins_key
  tags = {
    Name         = "Jenkins_key"
    ResourceName = "Key_pair"
    Owner        = var.resource_owner
  }
}

resource "aws_security_group" "jenkins_group" {
  name   = "jenkins_group"
  vpc_id = module.jenkins_vpc.id
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
    Owner        = var.resource_owner
  }
}

resource "aws_launch_configuration" "jenkins_LC" {
  name                 = "Jenkins_LC"
  image_id             = data.aws_ami.ubuntu_ami.id #latest ubuntu ami
  instance_type        = var.instance_type
  key_name             = aws_key_pair.jenkins_key.id
  security_groups      = [aws_security_group.jenkins_group.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.id
  user_data            = data.template_file.init.rendered
}

resource "aws_autoscaling_group" "jenkins_autosc_group" {
  name                 = "Jenkins_autosc_group"
  launch_configuration = aws_launch_configuration.jenkins_LC.name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = module.nat_network.priv_subnet_id
  load_balancers       = [aws_elb.jenkins-elb.id]
  target_group_arns    = [aws_lb_target_group.lb_target.arn]
  health_check_type    = "EC2"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_launch_configuration.jenkins_LC,
  aws_efs_file_system.efs_jenkins_home, aws_efs_mount_target.jenkins_efs_mount]

  tags = [
    {
      key                 = "ResourceName"
      value               = "Auto-scaling group"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = var.resource_owner
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
    Owner        = var.resource_owner
  }
}

resource "aws_efs_mount_target" "jenkins_efs_mount" {
  file_system_id  = aws_efs_file_system.efs_jenkins_home.id
  count           = length(module.nat_network.priv_subnet_id)
  subnet_id       = module.nat_network.priv_subnet_id[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group" "efs_sg" {
  name   = "efs_sg"
  vpc_id = module.jenkins_vpc.id
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
    Owner        = var.resource_owner
  }
}
resource "aws_ecr_repository" "ecr" {
  name                 = "ecr_images_from_jenkins"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name         = "ECR_images_from_jenkins"
    ResourceName = "ECR"
    Owner        = var.resource_owner
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
    account_id         = data.aws_caller_identity.current.account_id
    efs_address        = aws_efs_file_system.efs_jenkins_home.dns_name
    AWS_DEFAULT_REGION = var.AWS_DEFAULT_REGION
    cluster_name       = var.cluster_name
  }
}
