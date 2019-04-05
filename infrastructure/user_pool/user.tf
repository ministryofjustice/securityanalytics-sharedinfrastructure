data "aws_iam_policy_document" "sec_an_user" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      identifiers = ["cognito-identity.amazonaws.com"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "sec_an_user" {
  name               = "${terraform.workspace}-${var.app_name}-user"
  assume_role_policy = "${data.aws_iam_policy_document.sec_an_user.json}"
  path               = "/sec-an/${terraform.workspace}/user/"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}