resource "aws_s3_bucket" "dead_letter_store" {
  bucket = "${terraform.workspace}-${var.app_name}-dead-letters"

  tags = {
    app_name  = var.app_name
    workspace = terraform.workspace
  }
}