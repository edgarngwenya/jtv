resource "aws_route53_record" "cloudfront_route_53_cname" {
  zone_id = var.host_zone_id
  name = local.cloudfront_host_names
  type = var.environment_name == "dev" ? "CNAME" : "ALIAS"
  ttl = "300"
  records = [aws_cloudfront_distribution.distribution.domain_name]
}
