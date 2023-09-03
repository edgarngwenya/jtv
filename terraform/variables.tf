variable "environment_name" {
  type = string
  default = "dev"
}

variable "region" {
  type = string
  default = "eu-west-1"
}

variable "cloudfront_certificate_arn" {
  type = string
}

variable "cloudfront_public_key_id" {
  type = string
}

variable "host_zone_id" {
  type = string
}

variable "lambda_at_edge_arn" {
  type = string
}

data "aws_caller_identity" "current" {}
