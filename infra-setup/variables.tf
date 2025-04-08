variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

variable "environment_tag" {
  type        = string
  description = "Setup environment"
}

variable "application_name_tag" {
  type        = string
  description = "Application name"
}

variable "cost_center_tag" {
  type        = string
  description = "Cost center name"
}
