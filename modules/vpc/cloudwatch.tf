##CloudWatch log group [30 days retention]
resource "aws_cloudwatch_log_group" "vpc_log_group" {
  name              = "VPCFlowLogs"
  retention_in_days = 30

  tags = { Name = "${var.name-prefix}-VPC-Logs" }
}