/* Buil and push to ECR */

# Equivalent to 'aws ecr get-login'
data "aws_ecr_authorization_token" "ecr_token" {}

# Make a "docker build" and "docker push" if the hash of the Dockerfile directory change.
resource "null_resource" "push" {
  triggers = { always_run = "${timestamp()}" }

  provisioner "local-exec" {
    command = "echo ${data.aws_ecr_authorization_token.ecr_token.password}"
  }

  provisioner "local-exec" {
    #{push.sh} {aws_region} {aws_profile} {SOURCE_CODE} {ECR_URL} {IMAGE_TAG}
    command     = "${coalesce("${path.module}/scripts/push.sh")} ${var.aws_region} ${var.aws_profile} ${path.module}/docker/demo-app ${aws_ecr_repository.demo_app_flask_repository.repository_url} latest"
    interpreter = ["bash", "-c"]
  }
}

#Load the task definition template from a json.tpl file
data "template_file" "demo_app_tpl" {
  template = file("${path.module}/templates/demo-app.json.tpl")

  vars = {
    app_name      = var.demo_app["name"]
    app_image     = aws_ecr_repository.demo_app_flask_repository.repository_url
    aws_region    = var.aws_region
    app_port      = var.demo_app["port"]
    app_cw_group  = aws_cloudwatch_log_group.log_group.name
    app_cw_stream = aws_cloudwatch_log_stream.log_stream.name
    cpu           = var.demo_app["cpu"]
    memory        = var.demo_app["memory"]
  }
}

#Task definition
resource "aws_ecs_task_definition" "demo_app_td" {
  family                   = var.demo_app["name"]
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.demo_app["cpu"]
  memory                   = var.demo_app["memory"]
  container_definitions    = data.template_file.demo_app_tpl.rendered

  tags = { Name = "${var.name-prefix}-Demo-App-TD" }
}

#Service definition
resource "aws_ecs_service" "demo_app_service" {
  name                   = var.demo_app["name"]
  cluster                = aws_ecs_cluster.demo_cluster.id
  task_definition        = aws_ecs_task_definition.demo_app_td.arn
  desired_count          = 3
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  enable_execute_command = true

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = [var.private_subnet[0], var.private_subnet[1]]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.demo_app_tg.id
    container_name   = var.demo_app["name"]
    container_port   = var.demo_app["port"]
  }

  tags = { Name = "${var.name-prefix}-Demo-App-Srv" }

  depends_on = [aws_lb_listener.demo_app_listener]
}