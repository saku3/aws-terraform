data "aws_route53_zone" "route53_zone_data" {
  name = var.data_source_domain
}

resource "aws_route53_record" "sub_domain_ns_record" {
  allow_overwrite = true
  name            = var.domain
  ttl             = 86400
  type            = "NS"
  zone_id         = data.aws_route53_zone.route53_zone_data.zone_id

  records = [
    aws_route53_zone.route53_zone.name_servers[0],
    aws_route53_zone.route53_zone.name_servers[1],
    aws_route53_zone.route53_zone.name_servers[2],
    aws_route53_zone.route53_zone.name_servers[3],
  ]
}

# sub domain host zone
resource "aws_route53_zone" "route53_zone" {
  name = var.domain
}

resource "aws_route53_record" "route53_record" {
  zone_id = aws_route53_zone.route53_zone.id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
