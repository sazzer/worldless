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
