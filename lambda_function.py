import json
import boto3
import os

s3_client = boto3.client('s3')
sqs_client = boto3.client('sqs')

INPUT_BUCKET = os.environ['INPUT_BUCKET']
OUTPUT_BUCKET = os.environ['OUTPUT_BUCKET']
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    for record in event['Records']:
        file_name = record['s3']['object']['key']
        file_path = f"/tmp/{file_name}"
        
        # Download file from S3
        s3_client.download_file(INPUT_BUCKET, file_name, file_path)

        # Dummy Processing (Convert File Name to JSON)
        extracted_data = {"file_name": file_name, "status": "Processed"}

        # Store JSON in S3
        json_output_path = f"/tmp/{file_name}.json"
        with open(json_output_path, 'w') as json_file:
            json.dump(extracted_data, json_file)

        s3_client.upload_file(json_output_path, OUTPUT_BUCKET, f"{file_name}.json")

        # Send Message to SQS
        sqs_client.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps(extracted_data)
        )

    return {
        'statusCode': 200,
        'body': json.dumps(f"Processed {file_name} successfully.")
    }