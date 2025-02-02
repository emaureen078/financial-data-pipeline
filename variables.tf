variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "input_bucket_name" {
  description = "S3 bucket for document uploads"
  type        = string
  default     = "financial-documents-bucket"
}

variable "output_bucket_name" {
  description = "S3 bucket for processed data"
  type        = string
  default     = "processed-financial-data-bucket"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "financial_data_processor"
}

variable "sqs_queue_name" {
  description = "SQS queue name"
  type        = string
  default     = "financial-data-processing-queue"
}