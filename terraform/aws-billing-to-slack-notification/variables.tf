variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "SLACK_WEBHOOK_URL" {
  type      = string
  sensitive = true
}