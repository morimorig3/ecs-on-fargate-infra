# resource "aws_route53_zone" "main" {
#   name = "bita.jp"
# }

# resource "aws_route53_record" "corperate-producrion-record" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = aws_route53_zone.main.name
#   type    = "A"
#   alias {
#     name                   = aws_lb.this.dns_name
#     zone_id                = aws_lb.this.zone_id
#     evaluate_target_health = true
#   }
# }
