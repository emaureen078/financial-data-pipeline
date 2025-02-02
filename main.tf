provider "aws" {
  region = var.aws_region
}

# S3 Bucket for Uploading Financial Documents
resource "aws_s3_bucket" "input_bucket" {
  bucket = var.input_bucket_name
}

# S3 Bucket for Storing Processed Data
resource "aws_s3_bucket" "output_bucket" {
  bucket = var.output_bucket_name
}

# Create an SQS Queue for Processing
resource "aws_sqs_queue" "data_processing_queue" {
  name = var.sqs_queue_name
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_role" {
  name = "lambda_processing_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Lambda to Access S3 and SQS
resource "aws_iam_policy" "lambda_s3_sqs_policy" {
  name        = "LambdaS3SqsPolicy"
  description = "Allows Lambda to access S3 and SQS"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.input_bucket.arn}/*",
          "${aws_s3_bucket.output_bucket.arn}/*"
        ]
      },
      {
        Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage"]
        Effect   = "Allow"
        Resource = aws_sqs_queue.data_processing_queue.arn
      }
    ]
  })
}

# Attach IAM Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_sqs_policy.arn
}

# Lambda Function for Processing Financial Documents
resource "aws_lambda_function" "processing_lambda" {
  filename      = "lambda.zip"  # Ensure this is pre-packaged
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  environment {
    variables = {
      INPUT_BUCKET  = aws_s3_bucket.input_bucket.bucket
      OUTPUT_BUCKET = aws_s3_bucket.output_bucket.bucket
      SQS_QUEUE_URL = aws_sqs_queue.data_processing_queue.url
    }
  }
}

# S3 Event Notification to Trigger Lambda on New Upload
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processing_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# Grant S3 Permission to Invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processing_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}