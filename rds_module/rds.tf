resource "aws_db_subnet_group" "db_group" {
  name       = "main"
  subnet_ids = var.subnet_ids
  tags = {
    Name         = "RDS_subnet_db_group"
    ResourceName = "db_subnet_group"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_db_instance" "db" {
  allocated_storage      = var.alloc_storage
  storage_type           = var.db_stor_type
  engine                 = var.db_engine
  engine_version         = var.engine_ver
  instance_class         = var.db_instance
  name                   = var.db_name
  port                   = var.db_port
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  tags = {
    Name         = "RDS_db_instance"
    ResourceName = "RDS"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_security_group" "db_sg" {
  name   = "vpc_db"
  vpc_id = var.vpc_id
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.access_ip
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
