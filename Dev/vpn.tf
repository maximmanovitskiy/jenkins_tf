/*
resource "aws_ec2_client_vpn_endpoint" "eks_vpn_endp" {
  description            = "Client-VPN"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.vpn_cidr

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.root.arn
  }

  connection_log_options {
    enabled = false
    # cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    # cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }

  tags = {
    Name         = "VPN-EKS_endpoint"
    ResourceName = "VPN_endpoint"
    Owner        = var.resource_owner
  }
}

resource "aws_ec2_client_vpn_network_association" "vpn_assoc" {
  count                  = length(module.nat_network.priv_subnet_id)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.eks_vpn_endp.id
  subnet_id              = module.nat_network.priv_subnet_id[count.index]
  security_groups        = [aws_security_group.vpn_endpoint_grp.id]
}
resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.eks_vpn_endp.id
  target_network_cidr    = var.vpn_auth_grp_target
  authorize_all_groups   = true
}
resource "aws_ec2_client_vpn_route" "vpn_route" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.eks_vpn_endp.id
  destination_cidr_block = "0.0.0.0/0"
  count                  = length(module.nat_network.priv_subnet_id)
  target_vpc_subnet_id   = module.nat_network.priv_subnet_id[count.index]
}

resource "aws_security_group" "vpn_endpoint_grp" {
  name   = "vpn_endpoint_grp"
  vpc_id = module.vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.vpn_access_cidr
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name         = "VPN_endpoint_Sec_Group"
    ResourceName = "Security_group"
    Owner        = var.resource_owner
  }
}
*/
