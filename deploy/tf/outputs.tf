output "bucket_name" {
  value = aws_s3_bucket.ks.id
  description = "Name of the blog content bucket"
}
