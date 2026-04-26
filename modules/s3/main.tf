# 1. Create the Bucket
resource "aws_s3_bucket" "cbz_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "StaticWebsiteBucket"
    env  = "dev"
  }
}

# 2. Configure Static Website Hosting (Modern Approach)
resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.cbz_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# 3. Ownership Controls (Required to allow Public Access)
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.cbz_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# 4. Disable Block Public Access
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.cbz_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 5. Set Bucket Policy (Allow Public Read)
resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.cbz_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.cbz_bucket.arn}/*"
      }
    ]
  })

  # Ensure public access settings are applied BEFORE the policy
  depends_on = [
    aws_s3_bucket_public_access_block.example,
    aws_s3_bucket_ownership_controls.example,
  ]
}

# 6. Output the Endpoint
output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.hosting.website_endpoint
  description = "The URL to access the static website"
}
