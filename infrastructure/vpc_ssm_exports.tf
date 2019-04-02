locals {
  // annoyingly it doesn't seem to work if I replace this with keys(module.vpc.subnets)
  // actually it does once setup the first time, but not when bootstrapping
  // Will work with HCL2 in version 12 of terraform
  // TODO https://github.com/hashicorp/terraform/issues/16712
  subnet_types = ["instance", "public", "private"]
}

resource "aws_ssm_parameter" "subnets" {
  count       = "${length(local.subnet_types)}"
  name        = "/${var.app_name}/${terraform.workspace}/vpc/subnets/${local.subnet_types[count.index]}"
  description = "The ${var.app_name}'s vpc's ${local.subnet_types[count.index]} subnets"
  type        = "StringList"
  value       = "${join(",",module.vpc.subnets[local.subnet_types[count.index]])}"
  overwrite = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "using_private" {
  name        = "/${var.app_name}/${terraform.workspace}/vpc/using_private_subnets"
  description = "Whether the VPC has been configured to use private subnets"
  type        = "String"
  value       = "${var.use_private_subnets}"
  overwrite = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "cidr_block" {
  name        = "/${var.app_name}/${terraform.workspace}/vpc/cidr_block"
  description = "The ${var.app_name}'s vpc's cidr block"
  type        = "String"
  value       = "${module.vpc.cidr_block}"
  overwrite = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "id" {
  name        = "/${var.app_name}/${terraform.workspace}/vpc/id"
  description = "The ${var.app_name}'s vpc's id"
  type        = "String"
  value       = "${module.vpc.vpc_id}"
  overwrite = "true"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}
