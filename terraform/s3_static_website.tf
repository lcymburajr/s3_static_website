resource "aws_s3_bucket" "site" {
  bucket = "s3-static-website.test.com"
  acl    = "public-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "arn:aws:s3:::s3-static-website.test.com",
          "arn:aws:s3:::s3-static-website.test.com/*",
        ]
      },
    ]
  })

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "S3 Static Website"
  }
}

