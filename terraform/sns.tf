resource "aws_sns_topic" "trivy-topic" {
  name = "trivy-results"
  # Default delivery policy
  delivery_policy = <<-EOT
    {
        "http": {
            "defaultHealthyRetryPolicy": {
                "minDelayTarget": 20,
                "maxDelayTarget": 20,
                "numRetries": 3,
                "numMaxDelayRetries": 0,
                "numNoDelayRetries": 0,
                "numMinDelayRetries": 0,
                "backoffFunction": "linear"
            },
            "disableSubscriptionOverrides": false,
            "defaultThrottlePolicy": { "maxReceivesPerSecond": 1 }
        }
    }
    EOT
}

resource "aws_sns_topic_subscription" "trivy-topic-email" {
  topic_arn = aws_sns_topic.trivy-topic.arn
  protocol  = "email"
  endpoint  = var.email
}

# To get current account's ID for the policy
data "aws_caller_identity" "caller" {}

resource "aws_sns_topic_policy" "sns-trivy-policy" {
  policy = data.aws_iam_policy_document.sns-s3-policy.json
  arn    = aws_sns_topic.trivy-topic.arn
}

data "aws_iam_policy_document" "sns-s3-policy" {
  policy_id = "__default_policy_ID"
  statement {
    sid       = "S3-To-SNS"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.trivy-topic.arn]
    
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.trivy-results-bucket.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.caller.account_id]
    }
  }
}