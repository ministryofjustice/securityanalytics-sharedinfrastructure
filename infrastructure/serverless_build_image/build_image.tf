resource "aws_ecr_repository" "repo" {
  name = "${var.app_name}-build-repo-${terraform.workspace}"

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "null_resource" "build_image" {
  triggers {
    // hash tags make sure we redeploy on a change
    docker_hash = "${md5(file("Dockerfile"))}"
  }

  provisioner "local-exec" {
    command = "update_docker_image.sh sec-an-builder ${aws_ecr_repository.repo.repository_url} .  ${var.aws_region}"
  }
}
