region                = "us-east-1"
main_vpc_cidr_block   = "10.0.0.0/16"
elb_subnet_cidr_block = ["10.0.50.0/24", "10.0.51.0/24", "10.0.52.0/24"]
instance_type         = "t2.micro"
alb_ports             = ["80"]
elb_ports             = ["2222"]
access_ip             = [""]
resource_owner        = "Manovitskiy Maxim"
jenkins_key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmp60+GGnRIZJ9pe1F/xo7QGH7qhm23gx8ZAhVBK9Z5ysd7yyeQjMel7ZwmVYym9JWueY2eWhfJBGdnP68c2+EnAjNmZ8fsx7N9mBRYfmKjEh+wMMajZikONGk62q4a9QgrTrZCybErmNPPLdsgHwLulJ23uMWnxpDG4XGUlqMr+E1RlAYddWcpyPRND1TsGH5cy3+91SHUtFmQssTnQrPTntmUMAuFyRyAvAx94Xh0JiZi/4S1FKXwC2WMMgOC4HTQvLrC6zPkYIm9izT6LqEmZu+PxXLU5uiD8ghWyUcQ873RY8Lh3m9aa8tNv0GpOaywvymkE4p4jWnhHbOv+K+U0YLV1lVqg8m4qpPammHKpOg8/43aRDB1xTBGlpVIjTZhi7kqCj7r0DQaPy9A4KizGA7EDINaXsM6u31q+adCEjSzUrycQJutVpKezPkebpZYoMRa+qRnjS5mBH/AiNSuCH+s59GFvglZF7MkW4Nh3nVoLdGDkq/CahY+Rr3rnU="
lb_ssh_port           = 2222
