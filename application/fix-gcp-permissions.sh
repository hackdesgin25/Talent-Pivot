#!/bin/bash
# Fix GCP permissions for Container Registry push

echo "🔧 Fixing GCP permissions for Container Registry..."

PROJECT_ID="ltc-reboot25-team-51"
SERVICE_ACCOUNT="jenkins-talentpivot@$PROJECT_ID.iam.gserviceaccount.com"

echo "📋 Current project: $PROJECT_ID"
echo "🔑 Service account: $SERVICE_ACCOUNT"

# Set the project
gcloud config set project $PROJECT_ID

echo "🚀 Enabling required APIs first..."

# Enable Container Registry and Artifact Registry APIs
gcloud services enable containerregistry.googleapis.com
gcloud services enable artifactregistry.googleapis.com

echo "🚀 Adding missing Container Registry permissions..."

# Add Container Registry specific roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/storage.objectAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/containerregistry.ServiceAgent"

# Add Artifact Registry permissions (newer Google registry)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/artifactregistry.writer"

# CRITICAL: Add permission to create repositories on push
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/artifactregistry.repoAdmin"

# Add Cloud Build permissions (sometimes needed for registry operations)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/cloudbuild.builds.editor"

# Add additional required roles for full deployment
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/iam.serviceAccountUser"

echo "✅ GCP permissions updated!"
echo ""
echo "📋 Permissions granted:"
echo "   - roles/storage.objectAdmin (Container Registry storage)"
echo "   - roles/containerregistry.ServiceAgent (Container Registry service)"
echo "   - roles/artifactregistry.writer (Artifact Registry - newer)"
echo "   - roles/artifactregistry.repoAdmin (Repository creation permission)"
echo "   - roles/cloudbuild.builds.editor (Cloud Build for registry)"
echo "   - roles/run.admin (Cloud Run deployment)"
echo "   - roles/iam.serviceAccountUser (Service account usage)"
echo ""
echo "🎯 Next steps:"
echo "   1. Wait 1-2 minutes for permissions to propagate"
echo "   2. Re-run the Jenkins CD pipeline"
echo "   3. If still failing, check service account key in Jenkins"
echo ""
echo "🔍 To verify service account has correct permissions:"
echo "   gcloud projects get-iam-policy $PROJECT_ID --flatten='bindings[].members' --filter='bindings.members:serviceAccount:$SERVICE_ACCOUNT'"
