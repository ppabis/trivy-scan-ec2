resource "aws_s3_bucket" "trivy-results-bucket" {
  bucket = var.results-bucket-name
}

resource "aws_s3_bucket_notification" "trivy-results-notify" {
  bucket = aws_s3_bucket.trivy-results-bucket.bucket
  topic {
    topic_arn = aws_sns_topic.trivy-topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}