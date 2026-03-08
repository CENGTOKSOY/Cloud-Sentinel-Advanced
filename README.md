# Cloud-Sentinel-Advanced: Serverless Media Pipeline

A high-performance, **Event-Driven** cloud architecture simulated locally on **LocalStack**. This project demonstrates an asynchronous media processing pipeline using professional folder structures and **Infrastructure as Code (Terraform)**.

## 🏗️ Architecture
The system follows a decoupled microservices pattern:
1. **S3 (Input):** Trigger point for the entire pipeline.
2. **AWS Lambda (Processor):** Python-based serverless function triggered by S3 events.
3. **AWS SQS (Message Bus):** Ensures reliable communication between the processor and analytics engine.
4. **Terraform:** Automates the deployment of all AWS resources.



## 📂 Project Structure
\`\`\`text
├── infrastructure/    # Terraform modules & Docker configurations
├── services/          # Source code for Lambda and Consumer services
└── scripts/           # Automation and utility scripts
\`\`\`

## 🚀 Quick Start

### 1. Start LocalStack
\`\`\`bash
cd infrastructure/docker
docker compose up -d
\`\`\`

### 2. Deploy Infrastructure
\`\`\`bash
cd infrastructure/terraform/environments/localstack
terraform init
terraform apply -auto-approve
\`\`\`

## 🧪 Testing
Upload a file to the S3 bucket and check the SQS queue for the processed message:
\`\`\`bash
awslocal s3 cp README.md s3://sentinel-advanced-input/test.txt
awslocal sqs receive-message --queue-url http://localhost:4566/000000000000/sentinel-analytics-queue
\`\`\`

---
Developed by **Ali Gaffar Toksoy** as part of Cloud-Native Engineering studies.
