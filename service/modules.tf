module "users" {
  source = "./modules/users"

  common_tags = local.common_tags
  rest_api    = aws_api_gateway_rest_api.worldless
}
