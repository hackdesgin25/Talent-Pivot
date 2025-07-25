# PowerShell deployment script for TalentPivot to GCP Cloud Run

# Configuration
$PROJECT_ID = "lloyds-reboot"
$REGION = "us-central1"
$BUILD_TAG = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Host "🚀 Starting TalentPivot deployment to GCP..." -ForegroundColor Green

# Check if gcloud is authenticated
$authCheck = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null
if ([string]::IsNullOrEmpty($authCheck)) {
    Write-Host "❌ Not authenticated with gcloud. Please run: gcloud auth login" -ForegroundColor Red
    exit 1
}

# Set project
Write-Host "📝 Setting GCP project to $PROJECT_ID..." -ForegroundColor Yellow
gcloud config set project $PROJECT_ID

# Configure Docker for GCR
Write-Host "🐳 Configuring Docker for Google Container Registry..." -ForegroundColor Yellow
gcloud auth configure-docker --quiet

# Build and push frontend
Write-Host "🔨 Building frontend Docker image..." -ForegroundColor Yellow
docker build -t "gcr.io/$PROJECT_ID/talentpivot-frontend:$BUILD_TAG" .
Write-Host "📤 Pushing frontend image to GCR..." -ForegroundColor Yellow
docker push "gcr.io/$PROJECT_ID/talentpivot-frontend:$BUILD_TAG"

# Build and push backend
Write-Host "🔨 Building backend Docker image..." -ForegroundColor Yellow
Set-Location backend
docker build -t "gcr.io/$PROJECT_ID/talentpivot-backend:$BUILD_TAG" .
Write-Host "📤 Pushing backend image to GCR..." -ForegroundColor Yellow
docker push "gcr.io/$PROJECT_ID/talentpivot-backend:$BUILD_TAG"
Set-Location ..

# Deploy backend first
Write-Host "🚀 Deploying backend to Cloud Run..." -ForegroundColor Yellow
gcloud run deploy talentpivot-backend `
    --image "gcr.io/$PROJECT_ID/talentpivot-backend:$BUILD_TAG" `
    --region $REGION `
    --platform managed `
    --allow-unauthenticated `
    --port 8080 `
    --set-env-vars PORT=8080 `
    --set-env-vars NODE_ENV=production `
    --set-env-vars JWT_SECRET="your-super-secure-jwt-secret-key-here" `
    --set-env-vars SQL_HOST="34.63.181.90" `
    --set-env-vars SQL_USER="sqlserver" `
    --set-env-vars SQL_PASSWORD="TalentPivot@1" `
    --set-env-vars SQL_DATABASE="candidate_hub" `
    --set-env-vars SQL_PORT=3306

# Get backend URL
$BACKEND_URL = gcloud run services describe talentpivot-backend --region=$REGION --format="value(status.url)"
Write-Host "✅ Backend deployed at: $BACKEND_URL" -ForegroundColor Green

# Deploy frontend
Write-Host "🚀 Deploying frontend to Cloud Run..." -ForegroundColor Yellow
gcloud run deploy talentpivot-frontend `
    --image "gcr.io/$PROJECT_ID/talentpivot-frontend:$BUILD_TAG" `
    --region $REGION `
    --platform managed `
    --allow-unauthenticated `
    --set-env-vars VITE_API_URL="$BACKEND_URL/api/v1"

# Get frontend URL
$FRONTEND_URL = gcloud run services describe talentpivot-frontend --region=$REGION --format="value(status.url)"

Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
Write-Host "📱 Frontend URL: $FRONTEND_URL" -ForegroundColor Green
Write-Host "🔧 Backend URL: $BACKEND_URL" -ForegroundColor Green
Write-Host "⚠️  Remember to update your database credentials in the backend environment variables!" -ForegroundColor Yellow
