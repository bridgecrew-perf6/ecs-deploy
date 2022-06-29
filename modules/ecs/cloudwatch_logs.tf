##CloudWatch log group [30 days retention]
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/demo-app-logs"
  retention_in_days = 30

  tags = { Name = "${var.name-prefix}-Demo-App-logs" }
}

##CloudWatch log stream 
resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "demo-app-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}