output "vpc_cidr" {
  value = module.vpc.cidr
}
output "vpc_id" {
  value = module.vpc.id
}
output "vpn_dns" {
  value = aws_ec2_client_vpn_endpoint.eks_vpn_endp.dns_name
}
output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}
/*
output "private_key" {
  value = tls_private_key.root.private_key_pem
}
output "pub_key" {
  value = tls_locally_signed_cert.root.cert_pem
}
*/
