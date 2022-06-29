## SG Rule: Internet > ALB
resource "aws_security_group" "demo_app_sg" {
  name        = "demo_app_sg"
  description = "Allow public access to the ALB"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name-prefix}-Internet-To-ALB" }

  ingress {
    protocol    = "tcp"
    from_port   = var.demo_app["port"]
    to_port     = var.demo_app["port"]
    cidr_blocks = ["0.0.0.0/0"]
    description = "Internet to ALB"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## SG Rule: ALB > ECS
resource "aws_security_group" "ecs_tasks" {
  name        = "demo-app-tasks-sg"
  description = "Allow ALB to ECS ONLY"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name-prefix}-ALB-To-ECS" }

  ingress {
    protocol        = "tcp"
    from_port       = var.demo_app["port"]
    to_port         = var.demo_app["port"]
    security_groups = [aws_security_group.demo_app_sg.id]
    description     = "Demo App ALB to ECS"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}