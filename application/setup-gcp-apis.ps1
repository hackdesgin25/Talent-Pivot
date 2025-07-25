# PowerShell script for Windows - GCP API Setup for TalentPivot

Write-Host "🚀 Setting up GCP APIs for TalentPivot..." -ForegroundColor Green

# Set your project ID
$PROJECT_ID = "ltc-reboot25-team-51"
gcloud config set project $PROJECT_ID

Write-Host "📋 Enabling required APIs..." -ForegroundColor Yellow

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

Write-Host "✅ All APIs enabled successfully!" -ForegroundColor Green

# Create service account for CI/CD
Write-Host "🔑 Creating service account for Jenkins CI/CD..." -ForegroundColor Yellow
gcloud iam service-accounts create jenkins-ci `
    --display-name="Jenkins CI/CD Service Account" `
    --description="Service account for Jenkins CI/CD pipeline"

# Grant necessary roles
gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:jenkins-ci@$PROJECT_ID.iam.gserviceaccount.com" `
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:jenkins-ci@$PROJECT_ID.iam.gserviceaccount.com" `
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:jenkins-ci@$PROJECT_ID.iam.gserviceaccount.com" `
    --role="roles/iam.serviceAccountUser"

# Create and download service account key
gcloud iam service-accounts keys create jenkins-ci-key.json `
    --iam-account=jenkins-ci@$PROJECT_ID.iam.gserviceaccount.com

Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host "📁 Service account key saved as: jenkins-ci-key.json" -ForegroundColor Cyan
Write-Host "📋 Upload this key to Jenkins as 'gcp-key' credential" -ForegroundColor Cyan
