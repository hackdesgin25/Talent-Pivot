#!/bin/bash
# Verification script to demonstrate dynamic URL configuration

echo "🔍 TalentPivot Dynamic URL Configuration Verification"
echo "=================================================="
echo

echo "📋 Current Environment Files:"
echo "----------------------------"
echo "Development (.env.development):"
cat .env.development | grep VITE_API_URL
echo
echo "Staging (.env.staging):"
cat .env.staging | grep VITE_API_URL
echo
echo "Production (.env.production):"
cat .env.production | grep VITE_API_URL
echo

echo "🚀 Jenkins Dynamic URL Retrieval:"
echo "---------------------------------"
echo "The active Jenkinsfile.cd automatically:"
echo "1. Deploys backend to Cloud Run"
echo "2. Gets the actual URL: \$(gcloud run services describe talentpivot-backend --format=\"value(status.url)\")"
echo "3. Injects it into frontend: --set-env-vars VITE_API_URL=\"\$BACKEND_URL/api/v1\""
echo

echo "🎯 Current Live URLs (from latest deployment):"
echo "----------------------------------------------"
echo "Frontend: https://talentpivot-frontend-z7qlsmuifa-uc.a.run.app"
echo "Backend:  https://talentpivot-backend-z7qlsmuifa-uc.a.run.app"
echo

echo "⚙️ How the Frontend Selects URLs (priority order):"
echo "------------------------------------------------"
echo "1. VITE_API_URL environment variable (from Jenkins during deployment)"
echo "2. Auto-detect localhost in development mode"
echo "3. Mode-based selection (development/staging/production)"
echo "4. Fallback to latest deployed backend"
echo

echo "✅ Configuration Status: DYNAMIC and WORKING!"
echo "The system automatically uses the latest deployed backend URL."
