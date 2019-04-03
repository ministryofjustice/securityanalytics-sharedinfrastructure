resource "aws_ssm_parameter" "build-ecr" {
  name        = "/${var.app_name}/${terraform.workspace}/ecr/build"
  description = "The ecr repo for the build image"
  type        = "String"
  value       = "${module.build_ecr.build_ecr_url}"
  overwrite   = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}
