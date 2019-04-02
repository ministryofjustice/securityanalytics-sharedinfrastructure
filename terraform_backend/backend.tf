#############################################
# Variables used across the whole application
#############################################

variable "aws_region" {
  default = "eu-west-2" # london
}

variable "app_name" {
  default = "sec-an"
}

provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.app_name}"
}

#############################################
# Shared infrastructure
#############################################

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.app_name}-terraform-state"

  tags = {
    app_name = "${var.app_name}"
  }
}

resource "aws_dynamodb_table" "db" {
  name         = "${var.app_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  tags = {
    app_name = "${var.app_name}"
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
