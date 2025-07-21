output "api_gateway_endpoint" {
  value = aws_api_gateway_v2_api.api.api_endpoint
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
