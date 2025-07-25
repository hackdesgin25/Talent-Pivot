#!/bin/bash
# Manual deployment script for TalentPivot to GCP Cloud Run

set -e

# Configuration
PROJECT_ID="lloyds-reboot"
REGION="us-central1"
BUILD_TAG=$(date +%Y%m%d-%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting TalentPivot deployment to GCP...${NC}"

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo -e "${RED}❌ Not authenticated with gcloud. Please run: gcloud auth login${NC}"
    exit 1
fi

# Set project
echo -e "${YELLOW}📝 Setting GCP project to $PROJECT_ID...${NC}"
gcloud config set project $PROJECT_ID

# Configure Docker for GCR
echo -e "${YELLOW}🐳 Configuring Docker for Google Container Registry...${NC}"
gcloud auth configure-docker --quiet

# Build and push frontend
echo -e "${YELLOW}🔨 Building frontend Docker image...${NC}"
docker build -t gcr.io/$PROJECT_ID/talentpivot-frontend:$BUILD_TAG .
echo -e "${YELLOW}📤 Pushing frontend image to GCR...${NC}"
docker push gcr.io/$PROJECT_ID/talentpivot-frontend:$BUILD_TAG

# Build and push backend
echo -e "${YELLOW}🔨 Building backend Docker image...${NC}"
cd backend
docker build -t gcr.io/$PROJECT_ID/talentpivot-backend:$BUILD_TAG .
echo -e "${YELLOW}📤 Pushing backend image to GCR...${NC}"
docker push gcr.io/$PROJECT_ID/talentpivot-backend:$BUILD_TAG
cd ..

# Deploy backend first
echo -e "${YELLOW}🚀 Deploying backend to Cloud Run...${NC}"
gcloud run deploy talentpivot-backend \
    --image gcr.io/$PROJECT_ID/talentpivot-backend:$BUILD_TAG \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --port 8080 \
    --set-env-vars PORT=8080 \
    --set-env-vars NODE_ENV=production \
    --set-env-vars JWT_SECRET="your-super-secure-jwt-secret-key-here" \
    --set-env-vars SQL_HOST="your-sql-server-host" \
    --set-env-vars SQL_USER="your-sql-username" \
    --set-env-vars SQL_PASSWORD="your-sql-password" \
    --set-env-vars SQL_DATABASE="your-database-name" \
    --set-env-vars SQL_PORT=1433

# Get backend URL
BACKEND_URL=$(gcloud run services describe talentpivot-backend --region=$REGION --format="value(status.url)")
echo -e "${GREEN}✅ Backend deployed at: $BACKEND_URL${NC}"

# Deploy frontend
echo -e "${YELLOW}🚀 Deploying frontend to Cloud Run...${NC}"
gcloud run deploy talentpivot-frontend \
    --image gcr.io/$PROJECT_ID/talentpivot-frontend:$BUILD_TAG \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --set-env-vars VITE_API_URL="$BACKEND_URL/api/v1"

# Get frontend URL
FRONTEND_URL=$(gcloud run services describe talentpivot-frontend --region=$REGION --format="value(status.url)")

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${GREEN}📱 Frontend URL: $FRONTEND_URL${NC}"
echo -e "${GREEN}🔧 Backend URL: $BACKEND_URL${NC}"
echo -e "${YELLOW}⚠️  Remember to update your database credentials in the backend environment variables!${NC}"
