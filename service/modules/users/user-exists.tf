resource "aws_lambda_function" "user-exists" {
  function_name    = "${random_id.id.hex}-user-exists"
  filename         = "output/lambdas/users/user-exists.zip"
  source_code_hash = filebase64sha256("output/lambdas/users/user-exists.zip")
  handler          = "user-exists"
  role             = aws_iam_role.user-exists.arn
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 1
  tags             = local.common_tags

  environment {
    variables = {
      AWS_COGNITO_USERPOOL = aws_cognito_user_pool.worldless.id
    }
  }
}

resource "aws_iam_role" "user-exists" {
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  tags               = local.common_tags
}

data "template_file" "user-exists" {
  template = "${file("${path.module}/policies/user-exists.json")}"

  vars = {
    cognito_user_pool_arn = aws_cognito_user_pool.worldless.arn
  }
}

resource "aws_iam_policy" "user-exists" {
  policy = data.template_file.user-exists.rendered
}

resource "aws_iam_policy_attachment" "user-exists" {
  name = "user-exists"

  policy_arn = aws_iam_policy.user-exists.arn
  roles      = ["${aws_iam_role.user-exists.name}"]
}


resource "aws_api_gateway_resource" "user-exists" {
  rest_api_id = var.rest_api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{username}"
}

resource "aws_api_gateway_method" "user-exists" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.user-exists.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user-exists" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_method.user-exists.resource_id
  http_method = aws_api_gateway_method.user-exists.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.user-exists.invoke_arn
}

resource "aws_lambda_permission" "user-exists" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user-exists.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${var.rest_api.execution_arn}/*/*"
}
