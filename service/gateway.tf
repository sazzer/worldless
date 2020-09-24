# API Gateway for handling incoming HTTP requests
resource "aws_api_gateway_rest_api" "worldless" {
  name = "worldless"
  tags = local.common_tags
}

# API Gateway Deployment for connecting lambdas to the gateway
resource "aws_api_gateway_deployment" "worldless" {
  depends_on = [
    aws_api_gateway_integration.users-user-exists
  ]

  rest_api_id = aws_api_gateway_rest_api.worldless.id
  stage_name  = "v1"
}

output "base_url" {
  value = aws_api_gateway_deployment.worldless.invoke_url
}
