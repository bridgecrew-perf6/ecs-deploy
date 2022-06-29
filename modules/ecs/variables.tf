variable "name-prefix" {}
variable "aws_region" {}
variable "aws_profile" {}
variable "vpc_id" {}
variable "private_subnet" {}
variable "public_subnet" {}

variable "demo_app" {
  type = map(string)
  default = {
    "name"        = "demo_flask_app"
    "port"        = 8082
    "cpu"         = 1024
    "memory"      = 2048
    "healthcheck" = "/status"
  }
}