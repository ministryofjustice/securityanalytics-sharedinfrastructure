data "aws_iam_policy_document" "sns_logging_trust" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "sns_logging" {
  name               = "${terraform.workspace}-${var.app_name}-sns-logging"
  assume_role_policy = "${data.aws_iam_policy_document.sns_logging_trust.json}"
}

data "aws_iam_policy_document" "sns_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "sns_logging" {
  policy = "${data.aws_iam_policy_document.sns_logging.json}"
  role   = "${aws_iam_role.sns_logging.id}"
}
