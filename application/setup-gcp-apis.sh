#!/bin/bash
# GCP API Setup Script for TalentPivot

echo "🚀 Setting up GCP APIs for TalentPivot..."

# Set your project ID
PROJECT_ID="ltc-reboot25-team-51"
gcloud config set project $PROJECT_ID

echo "📋 Enabling required APIs..."

# Core APIs
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable compute.googleapis.com

# Storage & Database
gcloud services enable sql-component.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable storage.googleapis.com

# Identity & Security
gcloud services enable iam.googleapis.com
gcloud services enable iamcredentials.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Monitoring & Logging
gcloud services enable logging.googleapis.com
gcloud services enable monitoring.googleapis.com

echo "✅ All APIs enabled successfully!"

# Create service account for CI/CD
echo "🔑 Creating service account for Jenkins CI/CD..."
gcloud iam service-accounts create jenkins-ci \
    --display-name="Jenkins CI/CD Service Account" \
    --description="Service account for Jenkins CI/CD pipeline"

# Grant necessary roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:jenkins-ci@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:jenkins-ci@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:jenkins-ci@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

# Create and download service account key
gcloud iam service-accounts keys create jenkins-ci-key.json \
    --iam-account=jenkins-ci@$PROJECT_ID.iam.gserviceaccount.com

echo "🎉 Setup complete!"
echo "📁 Service account key saved as: jenkins-ci-key.json"
echo "📋 Upload this key to Jenkins as 'gcp-key' credential"
