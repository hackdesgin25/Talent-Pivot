# Switch to Google Artifact Registry (newer, more reliable than gcr.io)

Write-Host "🔄 Switching to Google Artifact Registry..." -ForegroundColor Yellow

$PROJECT_ID = "ltc-reboot25-team-51"
$SERVICE_ACCOUNT = "jenkins-talentpivot@$PROJECT_ID.iam.gserviceaccount.com"
$REGION = "us-central1"
$REPO_NAME = "talentpivot"

Write-Host "📋 Project: $PROJECT_ID" -ForegroundColor Cyan
Write-Host "🌍 Region: $REGION" -ForegroundColor Cyan
Write-Host "📦 Repository: $REPO_NAME" -ForegroundColor Cyan

# Set the project
gcloud config set project $PROJECT_ID

Write-Host "📋 Step 1: Enable Artifact Registry API..." -ForegroundColor Green
gcloud services enable artifactregistry.googleapis.com

Write-Host "📋 Step 2: Create Artifact Registry repository..." -ForegroundColor Green
gcloud artifacts repositories create $REPO_NAME --location=$REGION --repository-format=docker --description="TalentPivot Docker images"

Write-Host "📋 Step 3: Add required permissions..." -ForegroundColor Green
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/artifactregistry.writer"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/artifactregistry.reader"

Write-Host "📋 Step 4: Configure Docker authentication..." -ForegroundColor Green
gcloud auth configure-docker "$REGION-docker.pkg.dev" --quiet

Write-Host "✅ Artifact Registry setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 New registry URLs:" -ForegroundColor Cyan
Write-Host "   Frontend: $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/talentpivot-frontend" -ForegroundColor White
Write-Host "   Backend:  $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/talentpivot-backend" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Update Jenkinsfile.cd to use Artifact Registry URLs" -ForegroundColor White
Write-Host "   2. Re-run the Jenkins CD pipeline" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Registry URLs to use in Jenkinsfile.cd:" -ForegroundColor Cyan
Write-Host "   CONTAINER_REGISTRY = '$REGION-docker.pkg.dev'" -ForegroundColor Gray
Write-Host "   IMAGE_PREFIX = '$PROJECT_ID/$REPO_NAME'" -ForegroundColor Gray
