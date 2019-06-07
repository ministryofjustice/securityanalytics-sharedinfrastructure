resource "aws_ssm_parameter" "dead_letters_bucket_name" {
  name        = "/${var.app_name}/${terraform.workspace}/s3/dead_letters/name"
  description = "Name of the bucket used to store the dead letters the app generates"
  type        = "String"
  value       = aws_s3_bucket.dead_letter_store.id
  overwrite   = "true"

  tags = {
    app_name  = var.app_name
    workspace = terraform.workspace
  }
}

resource "aws_ssm_parameter" "dead_letters_bucket_arn" {
  name        = "/${var.app_name}/${terraform.workspace}/s3/dead_letters/arn"
  description = "Arn of the bucket used to store the dead letters the app generates"
  type        = "String"
  value       = aws_s3_bucket.dead_letter_store.arn
  overwrite   = "true"

  tags = {
    app_name  = var.app_name
    workspace = terraform.workspace
  }
}