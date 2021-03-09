resource "aws_ec2_client_vpn_endpoint" "default" {
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
    Owner        = "Maxim Manovitskiy"
  }
}

resource "aws_ec2_client_vpn_network_association" "default" {
  count                  = length(module.eks_subnets.id)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  subnet_id              = element(module.eks_subnets.id, count.index)
}
