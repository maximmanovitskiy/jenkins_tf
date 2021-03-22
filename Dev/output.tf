output "vpc_cidr" {
  value = module.vpc.cidr
}
output "vpc_id" {
  value = module.vpc.id
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}
output "ingress_policy_arn" {
  value = aws_iam_policy.ingress-controller-policy.arn
}
/*
output "private_key" {
  value = tls_private_key.root.private_key_pem
}
output "pub_key" {
  value = tls_locally_signed_cert.root.cert_pem
}
*/
