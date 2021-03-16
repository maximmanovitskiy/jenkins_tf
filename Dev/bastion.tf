module "bast_subnet" {
  source             = "../subnet_module"
  vpc_id             = module.vpc.id
  subnet_cidr_block  = var.bastion_cidr_block
  availability_zones = data.aws_availability_zones.available.names
  tags = {
    Name         = "Bastion_subnet"
    ResourceName = "VPC_subnet"
    Owner        = var.resource_owner
  }
}
resource "aws_route_table_association" "bast_pub_route" {
  subnet_id      = module.bast_subnet.id[count.index]
  count          = length(var.bastion_cidr_block)
  route_table_id = aws_route_table.route_table_eks.id
}

resource "aws_instance" "bastion" {
  ami                    = "ami-09ab237af4a23d09e"
  instance_type          = "t2.micro"
  subnet_id              = module.bast_subnet.id[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.bastion_key.id
  user_data              = data.template_file.bastion_script.rendered
  depends_on             = [module.eks]
  tags = {
    Name         = "Bastion_EC2"
    ResourceName = "EC2"
    Owner        = var.resource_owner
  }
}
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = var.public_key
  tags = {
    Name         = "EKS_node_key"
    ResourceName = "Key_pair"
    Owner        = var.resource_owner
  }
}
resource "aws_security_group" "bastion_sg" {
  name   = "bastion_sg"
  vpc_id = module.vpc.id
  dynamic "ingress" {
    for_each = [var.bast_ssh_port, var.bast_knock_port1,
    var.bast_knock_port2, var.bast_knock_port3]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.bastion_acc_ip
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name         = "Bastion_Sec_Group"
    ResourceName = "Security_group"
    Owner        = var.resource_owner
  }
}
data "template_file" "bastion_script" {
  template = file("./bastion.sh")
  vars = {
    bast_ssh_port         = var.bast_ssh_port
    bast_knock_port1      = var.bast_knock_port1
    bast_knock_port2      = var.bast_knock_port2
    bast_knock_port3      = var.bast_knock_port3
    AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION    = var.AWS_DEFAULT_REGION
    cluster_name          = var.eks_cluster_name
  }
}
