data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "codebucket" {
  bucket = "${var.project}-codebucket-${terraform.workspace}-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  tags = {
    Name = "${var.project}-codebucket-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_s3_bucket_object" "webapplication" {
  bucket = "${aws_s3_bucket.codebucket.id}"
  key    = "webapplication.zip"
  source = "${path.module}/webapplication.zip"
  etag   = "${md5(file("${path.module}/webapplication.zip"))}"
}