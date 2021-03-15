region                = "us-east-1"
main_vpc_cidr_block   = "10.0.0.0/16"
elb_subnet_cidr_block = ["10.0.50.0/24", "10.0.51.0/24", "10.0.52.0/24"]
instance_type         = "t2.micro"
alb_ports             = ["80"]
elb_ports             = ["2222"]
access_ip             = [""]
