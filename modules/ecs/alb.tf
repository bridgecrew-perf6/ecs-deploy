#Application Load Balancer (ALB): Internet > Demo-App ECS
resource "aws_lb" "demo_app_alb" {
  name               = "demo-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demo_app_sg.id]
  subnets            = [var.public_subnet[0], var.public_subnet[1]]

  tags = { Name = "${var.name-prefix}-ALB" }
}

#ALB Target
resource "aws_lb_target_group" "demo_app_tg" {
  name        = "demo-app-tg"
  port        = var.demo_app["port"]
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = { Name = "${var.name-prefix}-TG" }

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.demo_app["healthcheck"]
    unhealthy_threshold = "2"
  }
}

#ALB Listener
resource "aws_lb_listener" "demo_app_listener" {
  load_balancer_arn = aws_lb.demo_app_alb.id
  port              = var.demo_app["port"]
  protocol          = "HTTP"

  tags = { Name = "${var.name-prefix}-Listener" }

  default_action {
    target_group_arn = aws_lb_target_group.demo_app_tg.id
    type             = "forward"
  }
}