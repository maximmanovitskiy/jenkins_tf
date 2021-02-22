output "load_balancer_dns_name" {
  value = aws_elb.jenkins-elb.dns_name
}
output "efs_dns_name" {
  value = aws_efs_file_system.efs_jenkins_home.dns_name
}
