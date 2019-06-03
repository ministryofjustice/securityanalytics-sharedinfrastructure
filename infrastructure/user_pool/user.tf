data "aws_iam_policy_document" "sec_an_user" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }

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
  assume_role_policy = data.aws_iam_policy_document.sec_an_user.json
  path               = "/sec-an/${terraform.workspace}/user/"

  tags = {
    app_name  = var.app_name
    workspace = terraform.workspace
  }
}

# Annoying that we have to do this hear, rather than attach it when we setup analytics
resource "aws_iam_role_policy_attachment" "es_user" {
  role       = aws_iam_role.sec_an_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
}

