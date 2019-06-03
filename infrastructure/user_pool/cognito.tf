resource "aws_cognito_user_pool" "user_pool" {
  name = "${terraform.workspace}-${var.app_name}-users"

  admin_create_user_config {
    allow_admin_create_user_only = true

    invite_message_template {
      email_message = "You have been invited to use the security analytics application. Your user name is {username} and temporary password is {####}. You have 1 week in which to take up this invitation."
      email_subject = "You are invited to use the security analytics application"
      sms_message   = "Your user name is {username} and temporary password is {####}"
    }

    unused_account_validity_days = 7
  }

  auto_verified_attributes = ["email"]

  device_configuration {
    challenge_required_on_new_device = true
  }

  mfa_configuration = "OFF"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_symbols   = true
    require_numbers   = true
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = false

    string_attribute_constraints {
      max_length = "100"
      min_length = "1"
    }
  }

  schema {
    attribute_data_type = "String"
    name                = "given_name"
    required            = true
    mutable             = true

    string_attribute_constraints {
      max_length = "100"
      min_length = "1"
    }
  }

  schema {
    attribute_data_type = "String"
    name                = "family_name"
    required            = true
    mutable             = true

    string_attribute_constraints {
      max_length = "100"
      min_length = "1"
    }
  }

  username_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "Please confirm your email address using this code {####}"
    email_subject        = "Security analytics wants to confirm your identity"
  }

  tags = {
    app_name  = var.app_name
    workspace = terraform.workspace
  }
}

resource "aws_cognito_user_pool_domain" "user_pool" {
  domain       = "${terraform.workspace}-${var.app_name}-users"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "${replace(terraform.workspace, "-", " ")} ${replace(var.app_name, "-", " ")} user ids"
  allow_unauthenticated_identities = false

  # AWS Does way too much when setting up the elastic instance.
  # It creates an application client for the user pool and hooks it up to the identity pool
  # When terraform sees this change, it will go and remove the app client. This prevents that.
  lifecycle {
    ignore_changes = [cognito_identity_providers]
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "authenticated_user" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  roles = {
    authenticated = aws_iam_role.sec_an_user.arn
  }
}

