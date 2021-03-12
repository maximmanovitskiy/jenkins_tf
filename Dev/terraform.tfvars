eks_vpc_cidr_block         = "10.10.0.0/16"
eks_priv_subnet_cidr_block = ["10.10.100.0/24", "10.10.101.0/24"]
nat_pub_subnet_cidr_block  = ["10.10.150.0/24", "10.10.151.0/24"]
region                     = "us-east-1"
vpn_cidr                   = "10.10.0.0/22"
desired_node_number        = 2
max_node_number            = 2
min_node_number            = 1
pub_access                 = true
priv_access                = true
vpn_access_cidr            = ["0.0.0.0/0"]
vpn_auth_grp_target        = "0.0.0.0/0"
bastion_cidr_block         = ["10.10.50.0/24"]