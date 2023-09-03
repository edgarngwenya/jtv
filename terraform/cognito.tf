resource "aws_cognito_user_pool" "user_pool" {
  name  = "${var.environment_name}-engineering"

  auto_verified_attributes = [
    "email"
  ]
  username_attributes      = [
    "email"
  ]

  password_policy {
    minimum_length                   = 8
    temporary_password_validity_days = 7
  }

  username_configuration {
    case_sensitive = false
  }

  tags = local.common_tags
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name  = "${aws_cognito_user_pool.user_pool.name}Client"

  prevent_user_existence_errors = "ENABLED"

  refresh_token_validity = 30
  id_token_validity      = 1
  access_token_validity  = 1

  token_validity_units {
    refresh_token = "days"
    id_token      = "hours"
    access_token  = "hours"
  }

  user_pool_id        = aws_cognito_user_pool.user_pool.id
  generate_secret     = false
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  callback_urls                        = [
    "https://engineering.${var.environment_name}.cuvama.com/callback"
  ]


}

resource "aws_cognito_user_pool_domain" "hosted_ui_domain" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  domain       = "${var.environment_name}-engineering"
}
