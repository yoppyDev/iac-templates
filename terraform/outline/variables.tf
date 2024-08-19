variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "bundle_id" {
  type    = string
  default = "nano_3_0"
}

variable "blueprint_id" {
  type    = string
  default = "amazon_linux_2	"
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  sensitive   = true
}
