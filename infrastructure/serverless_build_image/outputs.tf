output "build_ecr_url" {
  value = "${aws_ecr_repository.repo.repository_url}"
}
