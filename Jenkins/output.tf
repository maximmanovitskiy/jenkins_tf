output "e_load_balancer_dns_name" {
  value = aws_elb.jenkins-elb.dns_name
}
output "a_load_balancer_dns_name" {
  value = aws_lb.jenkins_alb.dns_name
}
output "efs_dns_name" {
  value = aws_efs_file_system.efs_jenkins_home.dns_name
}
output "ecr_hostname" {
  value = aws_ecr_repository.ecr.repository_url
}
output "ecr_gw_hostname" {
  value = aws_ecr_repository.ecr-gateway.repository_url
}
