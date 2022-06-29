resource "aws_ecs_cluster" "demo_cluster" {
  name = "demo-cluster"

  tags = { Name = "${var.name-prefix}-Cluster" }
}

resource "aws_ecs_cluster_capacity_providers" "demo_cluster" {
  cluster_name = aws_ecs_cluster.demo_cluster.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}