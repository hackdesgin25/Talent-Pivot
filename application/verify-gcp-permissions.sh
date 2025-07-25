#!/bin/bash
# Verify GCP permissions for TalentPivot CD pipeline

echo "🔍 Verifying GCP permissions for TalentPivot CD pipeline..."

PROJECT_ID="ltc-reboot25-team-51"
SERVICE_ACCOUNT="jenkins-talentpivot@$PROJECT_ID.iam.gserviceaccount.com"

echo "📋 Project: $PROJECT_ID"
echo "🔑 Service Account: $SERVICE_ACCOUNT"
echo ""

# Set the project
gcloud config set project $PROJECT_ID

echo "✅ Checking service account permissions..."
echo ""

# Get all IAM bindings for our service account
echo "📊 Current IAM roles for service account:"
gcloud projects get-iam-policy $PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:$SERVICE_ACCOUNT" \
    --format="table(bindings.role)" | grep -v "ROLE" | sort

echo ""
echo "🔍 Required roles for Container Registry operations:"
echo "   ✓ roles/storage.objectAdmin (Container Registry storage)"
echo "   ✓ roles/containerregistry.ServiceAgent (Container Registry service)"
echo "   ✓ roles/artifactregistry.writer (Artifact Registry access)"
echo "   ✓ roles/artifactregistry.repoAdmin (Repository creation)"
echo "   ✓ roles/run.admin (Cloud Run deployment)"
echo "   ✓ roles/iam.serviceAccountUser (Service account usage)"
echo ""

echo "🔍 Checking enabled APIs..."
ENABLED_APIS=$(gcloud services list --enabled --format="value(config.name)" --filter="config.name:(containerregistry.googleapis.com OR artifactregistry.googleapis.com OR run.googleapis.com)")

if echo "$ENABLED_APIS" | grep -q "containerregistry.googleapis.com"; then
    echo "   ✅ Container Registry API: Enabled"
else
    echo "   ❌ Container Registry API: Not enabled"
fi

if echo "$ENABLED_APIS" | grep -q "artifactregistry.googleapis.com"; then
    echo "   ✅ Artifact Registry API: Enabled" 
else
    echo "   ❌ Artifact Registry API: Not enabled"
fi

if echo "$ENABLED_APIS" | grep -q "run.googleapis.com"; then
    echo "   ✅ Cloud Run API: Enabled"
else
    echo "   ❌ Cloud Run API: Not enabled"
fi

echo ""
echo "🎯 Next steps:"
echo "   1. If any APIs are missing, run: gcloud services enable <api-name>"
echo "   2. If permissions look correct, re-run the Jenkins CD pipeline"
echo "   3. The pipeline should now successfully push to gcr.io and deploy to Cloud Run"
echo ""
echo "🔧 To re-run CD pipeline manually:"
echo "   Go to Jenkins → talentpivot-cd → Build Now"
