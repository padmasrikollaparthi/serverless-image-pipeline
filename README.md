Serverless Event Processing Pipeline on GCP (Terraform + Cloud Functions Gen2)
## Project Overview

This project implements a real-time, serverless, event-driven pipeline on Google Cloud Platform (GCP) using Cloud Functions (Gen 2), Cloud Storage events, Pub/Sub, and Terraform.

It demonstrates how:

A user uploads a file via an HTTP endpoint

The file is stored in a Cloud Storage bucket

Storage events are published to Pub/Sub

Background functions process the event

Infrastructure is created using Terraform

This project focuses on serverless backend automation, real-time event processing, and infrastructure as code.

##Architecture (What Actually Happens)
Client (curl / API)
        |
        v
HTTP Cloud Function (upload-image)
        |
        v
Cloud Storage Bucket
        |
        v
GCS Event Notification
        |
        v
Pub/Sub Topic
        |
        v
Background Cloud Function (process-image)
        |
        v
Logging Cloud Function (log-notification)





Repository Structure
serverless-pipeline/
├── functions/
│   ├── main.py
│   ├── requirements.txt
│   ├── log-notification/
│   │   ├── main.py
│   │   └── requirements.txt
│   ├── process-image/
│   │   ├── main.py
│   │   └── requirements.txt
│   └── upload-image/
│       ├── main.py
│       ├── requirements.txt
│       └── upload.zip
├── terraform/
│   ├── apigw.yaml
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
├── process-function-source.zip
├── upload.zip
├── sample.png
├── test.txt
├── test-file.txt
└── submission.json
## Technologies Used

Google Cloud Platform (GCP)

Terraform – Infrastructure as Code

Cloud Functions (Gen 2)

Cloud Storage (GCS)

Pub/Sub

Cloud Run (Gen2 runtime)

Python 3

IAM (Access Control)

Cloud Logging

Cloud Shell

## What I Built in This Project
1. HTTP Upload Function (upload-image)

Accepts file uploads using an HTTP POST request.

Stores uploaded files into a Cloud Storage bucket.

Acts as the entry point for the event pipeline.

 2. Storage Event Processing Function (process-image)

Triggered automatically when a file is uploaded to the bucket.

Receives events via Pub/Sub.

Simulates file processing (metadata logging / processing logic).

3. Logging / Notification Function (log-notification)

Triggered by Pub/Sub messages.

Logs event information to Cloud Logging.

monstrates fan-out / multi-subscriber event processing.

 4. Infrastructure as Code (Terraform)

Created:

GCS bucket

Pub/Sub topic

IAM roles & service accounts

Cloud Functions (Gen 2)

API Gateway config (apigw.yaml)

Ensures reproducible deployment using Terraform.

##  How to Deploy
1. Initialize Terraform
terraform init
2. Apply Infrastructure
terraform apply

This provisions:

Cloud Storage bucket

Pub/Sub topic

Cloud Functions (upload-image, process-image, log-notification)

IAM permissions

3. Allow Public Access to HTTP Function
gcloud functions add-invoker-policy-binding upload-image \
  --region=us-central1 \
  --gen2 \
  --member="allUsers"
4. Upload a File (Trigger the Pipeline)
curl -X POST \
  -F "file=@sample.png" \
  https://us-central1-<PROJECT_ID>.cloudfunctions.net/upload-image
##  Logs & Debugging
gcloud functions logs read upload-image --region us-central1 --gen2
gcloud functions logs read process-image --region us-central1 --gen2
gcloud functions logs read log-notification --region us-central1 --gen2
##  Security

IAM roles are used with least-privilege access.

Only upload-image is public.

Background functions are private.

Service accounts are managed by Terraform.

## What I Learned

How to design event-driven serverless architectures

Deploying Cloud Functions Gen2 on GCP

Connecting Cloud Storage → Pub/Sub → Cloud Functions

Managing cloud resources using Terraform

Handling IAM permissions & 403 errors

Debugging serverless pipelines using Cloud Logs

Real-time cloud event processing

##  Testing Files

sample.png – Used for upload testing

test.txt, test-file.txt – Additional test objects

##  Cleanup (Avoid Charges)
terraform destroy

Or fully delete the project:

gcloud projects delete <PROJECT_ID>
##  Real-World Use Cases

Real-time file processing systems

Media upload & processing pipelines

Event-driven backend services

Serverless data ingestion

Cloud automation workflows
