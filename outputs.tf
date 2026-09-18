output "instance_id" {
  value = aws_instance.app_server.id
}

output "bucket_name" {
  value = aws_s3_bucket.data.bucket
}