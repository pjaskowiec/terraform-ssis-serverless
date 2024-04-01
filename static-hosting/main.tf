resource "aws_s3_bucket" "bucket" {
  bucket = "pj-mgr-website-bucket"
}

resource "aws_s3_bucket_public_access_block" "public_bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  depends_on = [aws_s3_bucket_public_access_block.public_bucket]
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
        }
      ]
    }
  )
}

resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/../static s3://${aws_s3_bucket.bucket.id}"
  }
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}