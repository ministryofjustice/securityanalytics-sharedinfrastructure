# This reporter consists of an s3 put object trigger which will send a message to the
# queue feeding elastic search with details of the new dead letter so that we can report
# on dead letters in kibana

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.results_parser.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.results_bucket_arn
}

resource "aws_s3_bucket_notification" "reporter_trigger" {
  depends_on = [aws_lambda_permission.s3_invoke]
  bucket     = var.results_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.dead_letter_reporter.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".tar.gz"
  }
}

resource "aws_lambda_function" "dlq_reporter" {
  function_name    = "${terraform.workspace}-${var.app_name}-dead-letter-reporter"
  handler          = "dead_letter_reporter.dead_letter_reporter.report_letters"
  role             = aws_iam_role.dlq_recorder.arn
  runtime          = "python3.7"
  filename         = "${path.module}/empty.zip"
  source_code_hash = filebase64sha256("${path.module}/empty.zip")

  layers = [
    data.aws_ssm_parameter.utils_layer.value,
    data.aws_ssm_parameter.dlq_recorder_layer.value,
  ]

  tracing_config {
    mode = var.use_xray ? "Active" : "PassThrough"
  }

  environment {
    variables = {
      REGION   = var.aws_region
      STAGE    = terraform.workspace
      APP_NAME = var.app_name
    }
  }

  tags = {
    workspace = terraform.workspace
    app_name  = var.app_name
  }
}

