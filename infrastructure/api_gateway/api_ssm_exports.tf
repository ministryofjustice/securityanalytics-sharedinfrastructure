resource "aws_ssm_parameter" "public_api_id" {
  name        = "/${var.app_name}/${terraform.workspace}/api/public/id"
  description = "Public Api gateway Id"
  type        = "String"
  value       = "${aws_api_gateway_rest_api.public_api.id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "public_api_root" {
  name        = "/${var.app_name}/${terraform.workspace}/api/public/root"
  description = "Public Api gateway root resource id"
  type        = "String"
  value       = "${aws_api_gateway_rest_api.public_api.root_resource_id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "public_api_authorizer" {
  name        = "/${var.app_name}/${terraform.workspace}/api/public/authorizer"
  description = "Public Api gateway root resource id"
  type        = "String"
  value       = "${aws_api_gateway_authorizer.public_api_authorizer.id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "private_api_id" {
  name        = "/${var.app_name}/${terraform.workspace}/api/private/id"
  description = "Private Api gateway Id"
  type        = "String"
  value       = "${aws_api_gateway_rest_api.private_api.id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "private_api_root" {
  name        = "/${var.app_name}/${terraform.workspace}/api/private/root"
  description = "Private Api gateway root resource id"
  type        = "String"
  value       = "${aws_api_gateway_rest_api.private_api.root_resource_id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "private_api_name" {
  name        = "/${var.app_name}/${terraform.workspace}/api/private/name"
  description = "Private Api gateway name"
  type        = "String"
  value       = "${terraform.workspace}-${var.app_name}-private-api"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}
