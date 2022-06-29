# Elastic Container Registry Definition
resource "aws_ecr_repository" "demo_app_flask_repository" {
  name                 = "demo_app_flask_repository"
  image_tag_mutability = "MUTABLE"
  tags                 = { Name = "${var.name-prefix}-ECR" }

  image_scanning_configuration {
    scan_on_push = false
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  for_each = toset([
    aws_ecr_repository.demo_app_flask_repository.name
  ])
  repository = each.key

  policy = <<EOF
  {
    "rules": [
      {
        "action": {
          "type": "expire"
        },
        "selection": {
          "countType": "imageCountMoreThan",
          "countNumber": 2,
          "tagStatus": "any"
        },
        "description": "Expire images older than 2 days",
        "rulePriority": 1
      }
    ]
  }
      EOF
}