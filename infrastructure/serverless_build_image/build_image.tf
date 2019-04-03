resource "aws_ecr_repository" "repo" {
  name = "${terraform.workspace}-${var.app_name}-build-repo"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "null_resource" "build_image" {
  triggers {
    // hash tags make sure we redeploy on a change
    docker_hash = "${md5(file("./serverless_build_image/Dockerfile"))}"
  }

  provisioner "local-exec" {
    command = "./serverless_build_image/update_docker_image.sh sec-an-builder ${aws_ecr_repository.repo.repository_url} .  ${var.aws_region}"
  }
}
