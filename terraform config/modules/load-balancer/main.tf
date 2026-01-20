# Load balancer creation

resource "aws_lb" "jenkins_alb" {
  name               = "zeus-jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids_public
  tags               = var.tags
}

# Target group for jenkins

resource "aws_lb_target_group" "lbtg_jenkins" {
  name     = "lbtg-jenkins"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
  }
}

# Target group for k8s
resource "aws_lb_target_group" "lbtg_k8s" {
  name     = "lbtg-k8s" # Unique name
  port     = 8082
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/" 
  }
}

# Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtg_jenkins.arn
    
  }
}
/*
resource "aws_lb_listener_rule" "k8s_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10 # Lower number = higher priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtg_k8s.arn
  }

  transform { 
    type = "url-rewrite"
    url_rewrite_config {
      rewrite {
        # Match the /k8s/ prefix and anything that follows (.*)
        # and replace the entire match with what follows (i.e., just the content of $1)
        regex   = "^/k8s/(.*)$"
        replace = "/$1" 
      }
    }
  }
  
  condition {
    path_pattern {
      values = [
        "/k8s/*",  # Matches /k8s/ and /k8s/index.html
        "/manager/*", # Matches /manager/html, /manager/status, etc.
        "/host-manager/*", # If you use the host manager
        "/my-webapp/*"
        ]
    }
  }
}
*/
resource "aws_autoscaling_attachment" "asg_attachment_jenkins" {
  autoscaling_group_name = var.jenkins_autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.lbtg_jenkins.arn
}


resource "aws_autoscaling_attachment" "asg_attachment_k8s" {
  autoscaling_group_name = var.k8s_autoscaling_group_name 
  lb_target_group_arn    = aws_lb_target_group.lbtg_k8s.arn
}