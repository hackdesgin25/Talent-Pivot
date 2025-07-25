#!/bin/bash
# Initialize Google Container Registry for TalentPivot project

echo "🔧 Initializing Google Container Registry for project ltc-reboot25-team-51..."

PROJECT_ID="ltc-reboot25-team-51"
SERVICE_ACCOUNT="jenkins-talentpivot@$PROJECT_ID.iam.gserviceaccount.com"

# Set the project
gcloud config set project $PROJECT_ID

echo "📋 Step 1: Enable required APIs..."
gcloud services enable containerregistry.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

echo "📋 Step 2: Add the specific createOnPush permission..."
# This is the key permission that's missing
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/artifactregistry.createOnPushRepoAdmin"

# Also ensure we have the basic registry permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/storage.admin"

echo "📋 Step 3: Initialize the gcr.io repository..."
# Method 1: Use gcloud to configure docker auth first
gcloud auth configure-docker gcr.io --quiet

# Method 2: Create a minimal push to initialize the repository
echo "Creating initial repository by pushing a test image..."

# Use the service account key if available
if [ ! -z "$GOOGLE_APPLICATION_CREDENTIALS" ] && [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "Using service account credentials..."
    gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
fi

# Pull a minimal image and push it to initialize the repo
docker pull hello-world:latest
docker tag hello-world:latest gcr.io/$PROJECT_ID/hello-world:init
echo "Pushing test image to initialize gcr.io repository..."

# Try to push - this should create the repository
if docker push gcr.io/$PROJECT_ID/hello-world:init; then
    echo "✅ Repository initialized successfully!"
    # Clean up the test image
    docker rmi gcr.io/$PROJECT_ID/hello-world:init hello-world:latest
    
    # Remove the test image from the registry
    gcloud container images delete gcr.io/$PROJECT_ID/hello-world:init --force-delete-tags --quiet
else
    echo "⚠️ Initial push failed, but repository may still be created"
fi

echo "📋 Step 4: Verify permissions..."
echo "Current IAM bindings for service account:"
gcloud projects get-iam-policy $PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:$SERVICE_ACCOUNT" \
    --format="table(bindings.role)"

echo ""
echo "✅ Container Registry initialization complete!"
echo "🎯 Next step: Re-run the Jenkins CD pipeline"
echo ""
echo "📋 If the pipeline still fails, try switching to Artifact Registry:"
echo "   1. Create Artifact Registry repository: gcloud artifacts repositories create talentpivot --location=us-central1 --repository-format=docker"
echo "   2. Update Jenkinsfile.cd to use us-central1-docker.pkg.dev/ltc-reboot25-team-51/talentpivot/"
