# Quick Fix Script - Update Cloud Run to use correct MySQL configuration
Write-Host "🔧 Quick Fix: Updating TalentPivot to use correct MySQL configuration" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Set your project details
$REGION = "us-central1"
$SERVICE_NAME = "talentpivot-backend"

Write-Host "📋 Cloud SQL Instance Details:" -ForegroundColor Yellow
Write-Host "   Type: MySQL 8.0" -ForegroundColor White
Write-Host "   Public IP: 34.63.181.90" -ForegroundColor White
Write-Host "   Port: 3306 (MySQL default)" -ForegroundColor White
Write-Host ""

Write-Host "🔄 Updating Cloud Run environment variables..." -ForegroundColor Cyan

try {
    gcloud run services update $SERVICE_NAME `
        --region=$REGION `
        --set-env-vars SQL_HOST="34.63.181.90" `
        --set-env-vars SQL_USER="sqlserver" `
        --set-env-vars SQL_PASSWORD="TalentPivot@1" `
        --set-env-vars SQL_DATABASE="candidate_hub" `
        --set-env-vars SQL_PORT=3306 `
        --quiet

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Environment variables updated successfully!" -ForegroundColor Green
        
        Write-Host "⏱️ Waiting for deployment to complete..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
        
        # Get service URL
        $serviceUrl = gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)" 2>$null
        
        Write-Host "🧪 Testing updated configuration..." -ForegroundColor Cyan
        Write-Host "🔗 Service URL: $serviceUrl" -ForegroundColor Green
        
        # Test health endpoint
        try {
            $null = Invoke-RestMethod -Uri "$serviceUrl/__health" -Method Get -TimeoutSec 10
            Write-Host "✅ Health endpoint responding" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️ Health endpoint not responding yet" -ForegroundColor Yellow
        }
        
        # Test database status endpoint
        try {
            Write-Host "🔍 Testing database connection..." -ForegroundColor Cyan
            $dbResponse = Invoke-RestMethod -Uri "$serviceUrl/__db-status" -Method Get -TimeoutSec 20
            
            if ($dbResponse.status -eq "OK") {
                Write-Host "🎉 SUCCESS! Database connection is working!" -ForegroundColor Green
            } else {
                Write-Host "❌ Database connection failed" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "❌ Database status endpoint failed" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "📊 Updated Configuration:" -ForegroundColor Cyan
        Write-Host "========================" -ForegroundColor Cyan
        Write-Host "Database Type: MySQL 8.0" -ForegroundColor White
        Write-Host "Host: 34.63.181.90" -ForegroundColor White
        Write-Host "Port: 3306" -ForegroundColor White
        
    } else {
        Write-Host "❌ Failed to update environment variables" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "❌ Error updating Cloud Run service: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⚠️ NEXT: Deploy updated MySQL code for full functionality" -ForegroundColor Yellow
