
# Autoscaling Outputs

output "jenkins_autoscaling_group_name" {
  description = "Autoscaling Group Name"
  value = aws_autoscaling_group.project_zeus_asg["jenkins"].name 
}

output "k8s_autoscaling_group_name" {
  description = "Autoscaling Group Name"
  value = aws_autoscaling_group.project_zeus_asg["k8s"].name 
}

output "ansible_autoscaling_group_name" {
  description = "Autoscaling Group Name"
  value = aws_autoscaling_group.ansible.name 
}