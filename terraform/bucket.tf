resource "aws_s3_bucket" "trivy-results-bucket" {
  bucket = var.results-bucket-name
}