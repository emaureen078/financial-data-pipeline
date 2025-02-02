# financial-data-pipeline
📂 financial-data-pipeline
│── 📄 main.tf               # Main Terraform script
│── 📄 variables.tf          # Variables for reusability
│── 📄 outputs.tf            # Outputs of Terraform deployment
│── 📄 lambda_function.py    # AWS Lambda function for processing
│── 📄 README.md             # Documentation
│── 📄 .gitignore            # Ignore Terraform state files & ZIP
│── 📄 lambda.zip            # Zip


# Financial Document Processing Pipeline

## Overview
This Terraform project builds a **data pipeline** that:
- Extracts data from **financial documents**.
- Processes the data using **AWS Lambda**.
- Stores structured data in **Amazon S3**.
- Uses **Amazon SQS** for message queuing.

## Deployment Steps
1. **Install Terraform & AWS CLI**
2. **Clone this repository**
   ```sh
   git clone https://github.com/yourusername/financial-data-pipeline.git
   cd financial-data-pipeline.
