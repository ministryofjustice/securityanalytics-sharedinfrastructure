resource "aws_ssm_parameter" "user_pool" {
  name        = "/${var.app_name}/${terraform.workspace}/cognito/pool/user"
  description = "Id of cognito user pool"
  type        = "String"
  value       = "${aws_cognito_user_pool.user_pool.id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "identity_pool" {
  name        = "/${var.app_name}/${terraform.workspace}/cognito/pool/identity"
  description = "Id of cognito identity pool"
  type        = "String"
  value       = "${aws_cognito_identity_pool.identity_pool.id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "cognito_user" {
  name        = "/${var.app_name}/${terraform.workspace}/users/sec-an/name"
  description = "${var.app_name} user Id"
  type        = "String"
  value       = "${aws_iam_role.sec_an_user.id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "cognito_user_arn" {
  name        = "/${var.app_name}/${terraform.workspace}/users/sec-an/arn"
  description = "${var.app_name} user Id"
  type        = "String"
  value       = "${aws_iam_role.sec_an_user.arn}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}
