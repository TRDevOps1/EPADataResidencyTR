resource "aws_s3_bucket" "data" {
  bucket = var.bucket_name

  tags = {
    Name = "data-bucket"
  }
}