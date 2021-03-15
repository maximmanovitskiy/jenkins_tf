module "bast_subnet" {
  source = "../subnet_module"

  vpc_id             = module.vpc.id
  subnet_cidr_block  = var.bastion_cidr_block
  availability_zones = data.aws_availability_zones.available.names
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
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9tGkZrP7SItDRdzwkAv3OXkoPlZ20WAA+MVrqI4MZZNhjmfRldsRxZ/hm7hEnF4YWYRKXQEigWLnqEnQusgaTjg2pkfp2nXi4ak+Jmv+b9pzp/KskI1+eCzDW+87L4sFp+p0yExEsf3DPqb+QW0VmyuK/ishkckQkrks1ESf3bI8Z0YDjqPKnU5pt6O+IhdwOwGZVsHaFtQU/xr3hO0lmdR3G88zylD0ljzZoRczt0aJgzfIjM74rDIcXQb4RXMDIex24TC628jLkYqnGzsUd4vIZPnAZdhfUTO7DlXlZX3/3VCaEU80hL/FWcMpJnK5xCuryuRXArg1SSRJJ0HCwQCN/sKwmK/woJdw+pNI8KYTw10MDLaD9FEiGQ6jyDXJ2G97tWN1pHmqkiPnUguunwZ7Q/uVRdbkjb+1X/3jhNyJAHa9tL42qH8t7IwTZB4XktvJMtaWoaH9BxYgtFLSX86wsnZ+tDp9sIkS0L+3e25QIdcqiRHjEPE9K705hblrZV+8ySZXWi6wT2Dra+0jOfbLS4aMUiExyJwHugPwqgEjYVWm1MJPjwm5KaWobwQ3UrVnGazcP8EfMWxi0EtQ9USi3/90JceEddXo9t7xHu6r0CjTCcc87VE+GLqJwXWwObfFnyBs2ge1hidY+UIGtx2tGxYZeMfMCD4pk6TQUVQ=="
  tags = {
    Name         = "EKS_node_key"
    ResourceName = "Key_pair"
    Owner        = "Maxim Manovitskiy"
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
    Owner        = "Maxim Manovitskiy"
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
