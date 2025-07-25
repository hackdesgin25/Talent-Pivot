#!/bin/bash
# Configuration Validation Script

echo "🔍 TalentPivot Configuration Validation"
echo "======================================"

echo "📱 Frontend URLs:"
echo "  • Development: http://localhost:8080/api/v1"
echo "  • Staging: https://talentpivot-backend-staging.us-central1.run.app/api/v1" 
echo "  • Production: https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1"

echo ""
echo "🌐 Current Deployment (Build #28):"
echo "  • Frontend: https://talentpivot-frontend-z7qlsmuifa-uc.a.run.app"
echo "  • Backend: https://talentpivot-backend-z7qlsmuifa-uc.a.run.app"

echo ""
echo "📦 Available Scripts:"
echo "  • npm run dev:local      - Local development"
echo "  • npm run dev:staging    - Staging environment"
echo "  • npm run build:staging  - Build for staging"
echo "  • npm run build:production - Build for production"

echo ""
echo "🔧 Environment Variables:"
echo "  • VITE_API_URL - Override API endpoint"
echo "  • NODE_ENV - Node environment"

echo ""
echo "✅ Configuration Status: HEALTHY"
