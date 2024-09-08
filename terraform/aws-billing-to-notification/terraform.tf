terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.63.0"
    }
  }

  cloud {
    organization = "YP"

    workspaces {
      name = "aws-billing-to-notification"
    }
  }
}