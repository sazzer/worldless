# The User Pool to contain user details
resource "aws_cognito_user_pool" "worldless" {
  name = "worldless-${terraform.workspace}"
  tags = local.common_tags

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 7
  }

  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration {
    enabled = true
  }

  username_configuration {
    case_sensitive = true
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true

    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  # Allow authentication using Username or Email Address
  alias_attributes = ["email"]
}

# User Pool Client details to allow interaction with user details
resource "aws_cognito_user_pool_client" "worldless" {
  name = "worldless-${terraform.workspace}"

  user_pool_id                 = aws_cognito_user_pool.worldless.id
  supported_identity_providers = ["COGNITO"]

  generate_secret     = true
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
}

# User Group to indicate a user is a system admin
resource "aws_cognito_user_group" "worldless" {
  name = "worldless-admin"

  user_pool_id = aws_cognito_user_pool.worldless.id
}

resource "aws_lambda_function" "users-user-exists" {
  function_name    = "${random_id.id.hex}-users-user-exists"
  filename         = "output/lambdas/users/user-exists.zip"
  source_code_hash = filebase64sha256("output/lambdas/users/user-exists.zip")
  handler          = "user-exists"
  role             = aws_iam_role.users-user-exists.arn
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

resource "aws_iam_role" "users-user-exists" {
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

data "template_file" "users-user-exists" {
  template = "${file("./iam/policies/users/user-exists.json")}"

  vars = {
    cognito_user_pool_arn = aws_cognito_user_pool.worldless.arn
  }
}

resource "aws_iam_policy" "users-user-exists" {
  policy = data.template_file.users-user-exists.rendered
}

resource "aws_iam_policy_attachment" "users-user-exists" {
  name = "users-user-exists"

  policy_arn = aws_iam_policy.users-user-exists.arn
  roles      = ["${aws_iam_role.users-user-exists.name}"]
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.worldless.id
  parent_id   = aws_api_gateway_rest_api.worldless.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "users-user-exists" {
  rest_api_id = aws_api_gateway_rest_api.worldless.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{username}"
}

resource "aws_api_gateway_method" "users-user-exists" {
  rest_api_id   = aws_api_gateway_rest_api.worldless.id
  resource_id   = aws_api_gateway_resource.users-user-exists.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "users-user-exists" {
  rest_api_id = aws_api_gateway_rest_api.worldless.id
  resource_id = aws_api_gateway_method.users-user-exists.resource_id
  http_method = aws_api_gateway_method.users-user-exists.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.users-user-exists.invoke_arn
}

resource "aws_lambda_permission" "users-user-exists" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.users-user-exists.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.worldless.execution_arn}/*/*"
}
