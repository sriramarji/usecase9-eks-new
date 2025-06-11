resource "aws_lb" "main" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [var.security_group_id]
  subnets            = var.subnets
  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true
  tags = {
    Name = "${var.name}-alb"
  }
}


# Define Target Group 1 (for the first ECS service)
resource "aws_lb_target_group" "ecs_target_group_1" {
  name     = "${var.name}-tg1"
  port     = 3001
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-404"
  }
}

# Define Target Group 2 (for the second ECS service)
resource "aws_lb_target_group" "ecs_target_group_2" {
  name     = "${var.name}-tg2"
  port     = 3000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-404"
  }

}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Healthcare Application - Try /patients or /appointments"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "ecs_listener_rule_1" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group_1.arn
  }

  condition {
    path_pattern {
      values = ["/appointments*"]
    }
  }
}




resource "aws_lb_listener_rule" "ecs_listener_rule_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group_2.arn
  }

  condition {
    path_pattern {
      values = ["/patients*"]
    }
  }
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "target_1" {
  value = aws_lb_target_group.ecs_target_group_1.arn
}

output "target_2" {
  value = aws_lb_target_group.ecs_target_group_2.arn
}
