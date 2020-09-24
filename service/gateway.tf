# API Gateway for handling incoming HTTP requests
resource "aws_api_gateway_rest_api" "worldless" {
  name = "worldless"
  tags = local.common_tags
}

# API Gateway Deployment for connecting lambdas to the gateway
resource "aws_api_gateway_deployment" "worldless" {
  depends_on = [
    module.users.gateway_integrations
  ]

  rest_api_id = aws_api_gateway_rest_api.worldless.id
  stage_name  = "v1"
}
