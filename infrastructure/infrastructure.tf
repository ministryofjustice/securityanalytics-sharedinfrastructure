#############################################
# Backend setup
#############################################

terraform {
  backend "s3" {
    # This is configured using the -backend-config parameter with 'terraform init'
    bucket         = ""
    dynamodb_table = "sec-an-terraform-locks"
    key            = "sec-an/terraform.tfstate"
    region         = "eu-west-2"                # london
  }
}

#############################################
# Variables used across the whole application
#############################################

variable "aws_region" {
  default = "eu-west-2" # london
}

# Set this variable with your app.auto.tfvars file or enter it manually when prompted
variable "app_name" {}

variable "use_private_subnets" {
  default = "false"
}

variable "create_nat_gateway" {
  default = "true"
}

variable "az_limit" {
  default = 1
}

variable "account_id" {}

provider "aws" {
  # N.B. To support all authentication use cases, we expect the local environment variables to provide auth details.
  region              = "${var.aws_region}"
  allowed_account_ids = ["${var.account_id}"]
}

#############################################
# Resources
#############################################

module "vpc" {
  source         = "vpc"
  app_name       = "${var.app_name}"
  create_private = "${var.use_private_subnets}"
  create_nat     = "${var.create_nat_gateway}"
  az_limit       = "${var.az_limit}"
}

module "user_pool" {
  source   = "user_pool"
  app_name = "${var.app_name}"
  api_url  = "${module.api_gateway.api_url}"
}

module "api_gateway" {
  source        = "api_gateway"
  app_name      = "${var.app_name}"
  user_pool_arn = "${module.user_pool.user_pool_arn}"
}

module "monitoring" {
  source   = "monitoring"
  app_name = "${var.app_name}"
}
