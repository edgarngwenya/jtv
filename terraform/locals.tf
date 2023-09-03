locals {
  cloudfront_host_names = var.environment_name == "dev" ? "dev.jaburo.tv" : "jaburo.tv"

  common_tags = {
    Environment = var.environment_name
  }
}
