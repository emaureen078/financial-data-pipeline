output "input_bucket" {
  description = "S3 bucket for document uploads"
  value       = aws_s3_bucket.input_bucket.bucket
}

output "output_bucket" {
  description = "S3 bucket for processed data"
  value       = aws_s3_bucket.output_bucket.bucket
}

output "lambda_function" {
  description = "Lambda function name"
  value       = aws_lambda_function.processing_lambda.function_name
}

output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.data_processing_queue.url
}