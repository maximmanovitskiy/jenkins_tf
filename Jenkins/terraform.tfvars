region                 = "us-east-1"
main_vpc_cidr_block    = "10.0.0.0/16"
pub_subnet_cidr_block  = ["10.0.50.0/24", "10.0.51.0/24", "10.0.52.0/24"]
priv_subnet_cidr_block = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
instance_type          = "t3.small"
alb_ports              = ["80"]
elb_ports              = ["2222"]
access_ip              = [""]
resource_owner         = "Maxim_Manovitskiy"
jenkins_key            = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9tGkZrP7SItDRdzwkAv3OXkoPlZ20WAA+MVrqI4MZZNhjmfRldsRxZ/hm7hEnF4YWYRKXQEigWLnqEnQusgaTjg2pkfp2nXi4ak+Jmv+b9pzp/KskI1+eCzDW+87L4sFp+p0yExEsf3DPqb+QW0VmyuK/ishkckQkrks1ESf3bI8Z0YDjqPKnU5pt6O+IhdwOwGZVsHaFtQU/xr3hO0lmdR3G88zylD0ljzZoRczt0aJgzfIjM74rDIcXQb4RXMDIex24TC628jLkYqnGzsUd4vIZPnAZdhfUTO7DlXlZX3/3VCaEU80hL/FWcMpJnK5xCuryuRXArg1SSRJJ0HCwQCN/sKwmK/woJdw+pNI8KYTw10MDLaD9FEiGQ6jyDXJ2G97tWN1pHmqkiPnUguunwZ7Q/uVRdbkjb+1X/3jhNyJAHa9tL42qH8t7IwTZB4XktvJMtaWoaH9BxYgtFLSX86wsnZ+tDp9sIkS0L+3e25QIdcqiRHjEPE9K705hblrZV+8ySZXWi6wT2Dra+0jOfbLS4aMUiExyJwHugPwqgEjYVWm1MJPjwm5KaWobwQ3UrVnGazcP8EfMWxi0EtQ9USi3/90JceEddXo9t7xHu6r0CjTCcc87VE+GLqJwXWwObfFnyBs2ge1hidY+UIGtx2tGxYZeMfMCD4pk6TQUVQ=="
lb_ssh_port            = 2222
cluster_name           = "nginx-eks"
jenkins_slave_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1BkLgceF/apZLgHbsF1al0HYqh+W4tizMsEnDr85SBKKdg8g2JpYOv456+scnkYO7yFFwfeYmQNf3dsKd3BPw+0pfYY2zaibpSW0ncZxIp6FblVJgKQeyuNkTnHk4N9EIL+iZlycC1j8G0+AJbrt/coz3lNKMSFwgH1dOWA7q2eChw+RfY26ovpwS2nDKIRymsKjYMRVYQ7roW3K6sui1wtZGLzcuIRq0SOTpkWkuZyP2qdy7fynm0uxLVzUzZb2vcnUPwhdMaK0pP1c7sLTBrGd5tQVxxqpZvMhR9BuPC+l5zEwzsfl17auRsFOcY3+4gR8FUvYGsMMOM/RRu7Ayi7Bjymho7W17hEWBOdfhui7iIhHpBQb8m72y20yEMz+Op3s+cH+TRVZFi9tEva1Dslmhl1jnxNz81WAfkz0WuVo3cduyzmXIs26KKa3tWvcy+OE+H1WJE5T27viirTkv+wyzj9MjH+xPzV64sUTu+5Wdch2W9K0XA2q+QHohr80="
