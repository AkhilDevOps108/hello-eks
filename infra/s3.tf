resource "aws_s3_bucket" "app" {
  bucket = "${var.project}-bucket-${random_id.rand.hex}"
  force_destroy = true
  tags = { Project = var.project }
}

resource "random_id" "rand" {
  byte_length = 3
}

output "bucket_name" { value = aws_s3_bucket.app.bucket }
