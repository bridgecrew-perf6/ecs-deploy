output "demo_app_alb_dns" {
  value = "http://${aws_lb.demo_app_alb.dns_name}:${var.demo_app["port"]}"
}