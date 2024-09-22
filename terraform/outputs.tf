output "instance_ip" {
  description = "The public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.static_content.bucket
}
