terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      application = var.application_name_tag
      environment = var.environment_tag
      cost_center = var.cost_center_tag
    }
  }
}
