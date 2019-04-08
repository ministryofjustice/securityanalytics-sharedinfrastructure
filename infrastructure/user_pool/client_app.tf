resource "aws_cognito_user_pool_client" "client" {
  name = "${terraform.workspace}-${var.app_name}-users"

  # TODO replace hosted ui and password auth with SRP based auth or other (i.e this becomes code)
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "profile", "email"]
  callback_urls                        = ["${var.api_url}"]
  default_redirect_uri                 = "${var.api_url}"

  # TODO replace hosted ui and password auth with SRP based auth or other ( i.e. this becomes CUSTOM_AUTH_FLOW_ONLY)
  explicit_auth_flows          = ["USER_PASSWORD_AUTH"]
  generate_secret              = false
  read_attributes              = ["email", "family_name", "given_name"]
  supported_identity_providers = ["COGNITO"]

  user_pool_id = "${aws_cognito_user_pool.user_pool.id}"
}
