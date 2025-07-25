# Fix GCP permissions for Container Registry push

Write-Host "🔧 Fixing GCP permissions for Container Registry..." -ForegroundColor Yellow

$PROJECT_ID = "ltc-reboot25-team-51"
$SERVICE_ACCOUNT = "jenkins-talentpivot@$PROJECT_ID.iam.gserviceaccount.com"

Write-Host "📋 Current project: $PROJECT_ID" -ForegroundColor Cyan
Write-Host "🔑 Service account: $SERVICE_ACCOUNT" -ForegroundColor Cyan

# Set the project
gcloud config set project $PROJECT_ID

Write-Host "🚀 Adding missing Container Registry permissions..." -ForegroundColor Green

# Enable required APIs first
Write-Host "🔧 Enabling Container Registry API..." -ForegroundColor Yellow
gcloud services enable containerregistry.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Add Container Registry specific roles
Write-Host "🔑 Adding Container Registry permissions..." -ForegroundColor Green
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/storage.objectAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/containerregistry.ServiceAgent"

# Add Artifact Registry permissions (newer Google registry)
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/artifactregistry.writer"

# CRITICAL: Add permission to create repositories on push
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/artifactregistry.repoAdmin"

# Add Cloud Build permissions (sometimes needed for registry operations)
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/cloudbuild.builds.editor"

# Create the gcr.io repository manually to avoid push-time creation issues
Write-Host "📦 Creating Container Registry repository..." -ForegroundColor Cyan
gcloud auth activate-service-account --key-file="$env:GOOGLE_APPLICATION_CREDENTIALS" 2>$null
docker pull hello-world 2>$null
docker tag hello-world gcr.io/$PROJECT_ID/hello-world 2>$null
docker push gcr.io/$PROJECT_ID/hello-world 2>$null
docker rmi gcr.io/$PROJECT_ID/hello-world hello-world 2>$null
Write-Host "✅ Container Registry initialized" -ForegroundColor Green

# Add additional required roles for full deployment
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/iam.serviceAccountUser"

Write-Host "✅ GCP permissions updated!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Permissions granted:" -ForegroundColor Cyan
Write-Host "   - roles/storage.objectAdmin (Container Registry storage)" -ForegroundColor White
Write-Host "   - roles/containerregistry.ServiceAgent (Container Registry service)" -ForegroundColor White
Write-Host "   - roles/artifactregistry.writer (Artifact Registry - newer)" -ForegroundColor White
Write-Host "   - roles/artifactregistry.repoAdmin (Repository creation permission)" -ForegroundColor White
Write-Host "   - roles/cloudbuild.builds.editor (Cloud Build for registry)" -ForegroundColor White
Write-Host "   - roles/run.admin (Cloud Run deployment)" -ForegroundColor White
Write-Host "   - roles/iam.serviceAccountUser (Service account usage)" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Wait 1-2 minutes for permissions to propagate" -ForegroundColor White
Write-Host "   2. Re-run the Jenkins CD pipeline" -ForegroundColor White
Write-Host "   3. If still failing, check service account key in Jenkins" -ForegroundColor White
Write-Host ""
Write-Host "🔍 To verify service account has correct permissions:" -ForegroundColor Cyan
Write-Host "   gcloud projects get-iam-policy $PROJECT_ID --flatten='bindings[].members' --filter='bindings.members:serviceAccount:$SERVICE_ACCOUNT'" -ForegroundColor Gray
