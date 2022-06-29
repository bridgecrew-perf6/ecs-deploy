# Create an "IAM role" for ECS "Tasks Definition" with an inline policy that allow read parameter from System Manager

# ECS IAM Policy Document
data "aws_iam_policy_document" "ecs_policy_source" {
  statement {
    sid    = "CloudWatchPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPolicy"
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECSPolicy"
    effect = "Allow"
    actions = [
      "ecs:CreateService",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:ListContainerInstances",
      "ecs:StopTask",
      "ecs:DescribeTasks",
      "ecs:DescribeContainerInstances",
      "ecs:ListTaskDefinitions",
      "ecs:DeregisterTaskDefinition",
      "ecs:UpdateService"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SSMPolicy"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "KMSPolicy"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

# ECS IAM Role Policy Document
data "aws_iam_policy_document" "ecs_role_source" {
  statement {
    sid    = "ECSAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# ECS IAM Policy
resource "aws_iam_policy" "ecs_policy" {
  name   = "${var.name-prefix}-Policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_policy_source.json
  tags   = { Name = "${var.name-prefix}-Policy" }
}

# ECS IAM Role (ECS Task Execution role)
resource "aws_iam_role" "ecs_role" {
  name               = "${var.name-prefix}-Role"
  assume_role_policy = data.aws_iam_policy_document.ecs_role_source.json
  tags               = { Name = "${var.name-prefix}-Role" }
}

# Attach ecs Role and Policy
resource "aws_iam_role_policy_attachment" "ecs_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}