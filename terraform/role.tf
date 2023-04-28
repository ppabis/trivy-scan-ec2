resource "aws_iam_role" "ec2-trivy" {
  name               = "ec2-trivy"
  assume_role_policy = <<EOF
    { 
      "Version": "2012-10-17",
      "Statement": [ {
        "Action": "sts:AssumeRole",
        "Principal": { "Service": "ec2.amazonaws.com" },
        "Effect": "Allow",
        "Sid": ""
      } ]
    }
    EOF
}

resource "aws_iam_instance_profile" "ec2-trivy" {
  name = "ec2-trivy"
  role = aws_iam_role.ec2-trivy.name
}

resource "aws_iam_policy" "trivy-results" {
  name   = "Trivy-Results"
  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
            "Sid": "Cloudwatch",
            "Effect": "Allow",
            "Action": [ "cloudwatch:PutMetricData" ],
            "Resource": "*"
        },
        {
            "Sid": "S3",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.trivy-results-bucket.arn}",
                "${aws_s3_bucket.trivy-results-bucket.arn}/*"
            ]
        }
      ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "trivy-results" {
  role       = aws_iam_role.ec2-trivy.name
  policy_arn = aws_iam_policy.trivy-results.arn
}