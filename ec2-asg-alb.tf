#####Target Group
resource "aws_lb_target_group" "ussd_api" {
  name = "ussd-api-tg"
  port = "8080"
  protocol = "HTTP"
  vpc_id = "vpc-008344e6577e5259c"
  health_check {
    path = "/health"
    port = 8080
    healthy_threshold = 10
    unhealthy_threshold = 10
    timeout = 3
    interval = 5
    matcher = "200"
  }
}

resource "aws_lb" "ussd_api" {
    name               = "ussdapi-lb"
    internal           = false
    load_balancer_type = "application"
    enable_deletion_protection = false
    security_groups    = ["sg-01f3b7e827f9ed30c"]
    subnets            = ["subnet-0def7a0a927cb38e5", "subnet-0b99eacc0848e8019"]
    tags = {
      Environment = "production"
    }
  }

resource "aws_lb_listener" "ussd_api" {
  load_balancer_arn = aws_lb.ussd_api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ussd_api.arn
  }
}

output "ussd_alb_dns" {
  value = aws_lb.ussd_api.dns_name
}