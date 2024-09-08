variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "WEBHOOK_URL" {
  type      = string
  sensitive = true
}
variable "NOTIFICATION_SERVICE" {
  type      = string
  default   = "discord"
}
