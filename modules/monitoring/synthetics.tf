# -----------------------------------------------------
# CloudWatch Synthetics artifact bucket
# -----------------------------------------------------

resource "aws_s3_bucket" "synthetics_artifacts" {
  bucket_prefix = "${local.resource_name_prefix}-synthetics-"

  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-synthetics"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "synthetics_artifacts" {
  bucket = aws_s3_bucket.synthetics_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "synthetics_artifacts" {
  bucket = aws_s3_bucket.synthetics_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "synthetics_artifacts" {
  bucket = aws_s3_bucket.synthetics_artifacts.id

  rule {
    id     = "delete-old-canary-artifacts"
    status = "Enabled"

    filter {}

    expiration {
      days = var.canary_artifact_retention_days
    }
  }
}

# -----------------------------------------------------
# CloudWatch Synthetics IAM role
# -----------------------------------------------------

resource "aws_iam_role" "synthetics_canary" {
  name = "${local.resource_name_prefix}-synthetics-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "synthetics_canary" {
  name = "${local.resource_name_prefix}-synthetics-policy"
  role = aws_iam_role.synthetics_canary.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "SyntheticsArtifactBucket"
        Effect = "Allow"

        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.synthetics_artifacts.arn
      },
      {
        Sid    = "SyntheticsArtifactObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.synthetics_artifacts.arn}/*"
      },
      {
        Sid    = "SyntheticsCloudWatchLogs"
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "SyntheticsCloudWatchMetrics"
        Effect = "Allow"

        Action = [
          "cloudwatch:PutMetricData"
        ]

        Resource = "*"

        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "CloudWatchSynthetics"
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------
# Package the canary JavaScript
# -----------------------------------------------------

data "archive_file" "webpage_canary" {
  type        = "zip"
  output_path = "${path.module}/webpage-canary.zip"

  source {
    filename = "nodejs/node_modules/heartbeat.js"

    content = <<-EOT
      const synthetics = require('@aws/synthetics-puppeteer');

      const checkWebpage = async function () {
        const webpageUrl = process.env.WEBPAGE_URL;

        if (!webpageUrl) {
          throw new Error('WEBPAGE_URL environment variable is not set');
        }

        await synthetics.executeHttpStep(
          'Check webpage availability',
          webpageUrl,
          function validateResponse(response) {
            if (
              response.statusCode < 200 ||
              response.statusCode >= 400
            ) {
              throw new Error(
                'Webpage returned HTTP status code ' +
                response.statusCode
              );
            }
          }
        );
      };

      exports.handler = async () => {
        return await checkWebpage();
      };
    EOT
  }
}

# -----------------------------------------------------
# Webpage heartbeat canary
# -----------------------------------------------------

resource "aws_synthetics_canary" "webpage_uptime" {
  name = substr(
    "${local.resource_name_prefix}-webpage",
    0,
    21
  )

  artifact_s3_location = "s3://${aws_s3_bucket.synthetics_artifacts.id}/"
  execution_role_arn   = aws_iam_role.synthetics_canary.arn

  handler         = "heartbeat.handler"
  zip_file        = data.archive_file.webpage_canary.output_path
  runtime_version = var.canary_runtime_version

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
    memory_in_mb       = 960

    environment_variables = {
      WEBPAGE_URL = var.webpage_url
    }
  }

  success_retention_period = var.canary_success_retention_days
  failure_retention_period = var.canary_failure_retention_days

  tags = {
    Name        = "${var.project_name}-${var.environment}-webpage-uptime"
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy.synthetics_canary,
    aws_s3_bucket_public_access_block.synthetics_artifacts,
    aws_s3_bucket_server_side_encryption_configuration.synthetics_artifacts
  ]
}

# -----------------------------------------------------
# Webpage availability alarm
# -----------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "webpage_uptime" {
  alarm_name = "${var.project_name}-${var.environment}-webpage-unavailable"

  alarm_description = "The application webpage failed two consecutive CloudWatch Synthetics checks"

  namespace   = "CloudWatchSynthetics"
  metric_name = "SuccessPercent"

  dimensions = {
    CanaryName = aws_synthetics_canary.webpage_uptime.name
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 100
  comparison_operator = "LessThanThreshold"

  treat_missing_data = "breaching"
}