variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_profile" {
  type    = string
  default = ""
}

/* Tags Variables */
variable "project-tags" {
  type = map(string)
  default = {
    service     = "ECS-POC",
    environment = "POC"
    DeployedBy  = "example@mail.com"
  }
}

#Usage: tags = { Name = "${var.name-prefix}-lambda" }
variable "name-prefix" {
  type    = string
  default = "ECS-POC"
}