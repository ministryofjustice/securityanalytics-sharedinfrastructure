#############################################
# Variables used across the whole application
#############################################

variable "aws_region" {
  default = "eu-west-2" # london
}

# Set this variable with your app.auto.tfvars file or enter it manually when prompted
variable "app_name" {}

provider "aws" {
  region = "${var.aws_region}"

  # profile set in env variables to support MFA
  # profile = "${var.app_name}"
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

resource "aws_iam_user" "circle_ci" {
  name = "${var.app_name}-circle-ci"

  tags = {
    app_name = "${var.app_name}"
  }
}

data "aws_iam_policy_document" "access_terraform" {
  statement {
    effect = "Allow"

    actions = [
      "s3:DeleteObject*",
      "s3:Get*",
      "s3:List*",
      "s3:PutObject*",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}",
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["${aws_dynamodb_table.db.arn}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:GetUser"]
    resources = ["${aws_iam_user.circle_ci.arn}"]
  }
}

resource "aws_iam_policy" "terraform_access" {
  name   = "${var.app_name}-terraform-access"
  policy = "${data.aws_iam_policy_document.access_terraform.json}"
}

resource "aws_iam_policy_attachment" "terraform_access" {
  name       = "${var.app_name}-terraform-access"
  users      = ["${aws_iam_user.circle_ci.id}"]
  policy_arn = "${aws_iam_policy.terraform_access.arn}"
}
