output "lb_dns_name" {
  description = "DNS name of lb"
  value       = aws_lb.jenkins_alb.dns_name
}