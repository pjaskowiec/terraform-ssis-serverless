resource "aws_ecr_repository" "pj-mgr-registry" {
  name                 = "pj-mgr-registry"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}