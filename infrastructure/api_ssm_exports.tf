resource "aws_ssm_parameter" "api_id" {
  name        = "/${var.app_name}/${terraform.workspace}/api/id"
  description = "Api gateway Id"
  type        = "String"
  value       = "${aws_api_gateway_rest_api.api.id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "api_root" {
  name        = "/${var.app_name}/${terraform.workspace}/api/root"
  description = "Api gateway root resource id"
  type        = "String"
  value       = "${aws_api_gateway_rest_api.api.root_resource_id}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}
