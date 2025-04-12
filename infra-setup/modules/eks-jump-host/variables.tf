variable "subnet_id" {
  type        = string
  description = "List of subnets ids"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "merged_tags" {
  type        = map(string)
  description = "merged tags"
}
