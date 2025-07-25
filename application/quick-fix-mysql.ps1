# Quick Fix Script - Update Cloud Run to use correct MySQL configuration
# This script immediately updates the running Cloud Run instance with correct database settings

Write-Host "🔧 Quick Fix: Updating TalentPivot to use correct MySQL configuration" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Set your project details
$PROJECT_ID = "ltc-reboot25-team-51"
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
        
        # Test health endpoint
        try {
            $null = Invoke-RestMethod -Uri "$serviceUrl/__health" -Method Get -TimeoutSec 10
            Write-Host "✅ Health endpoint responding" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️ Health endpoint not responding yet (service may still be starting)" -ForegroundColor Yellow
        }
        
        # Test database status endpoint
        try {
            Write-Host "🔍 Testing database connection..." -ForegroundColor Cyan
            $dbResponse = Invoke-RestMethod -Uri "$serviceUrl/__db-status" -Method Get -TimeoutSec 20
            
            if ($dbResponse.status -eq "OK") {
                Write-Host "🎉 SUCCESS! Database connection is working!" -ForegroundColor Green
                Write-Host "Database: $($dbResponse.database.database) on $($dbResponse.database.host):$($dbResponse.database.port)" -ForegroundColor Green
            } else {
                Write-Host "❌ Database connection failed: $($dbResponse.message)" -ForegroundColor Red
                Write-Host "Check Cloud SQL instance status and network configuration" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "❌ Database status endpoint failed: $_" -ForegroundColor Red
            Write-Host "This indicates the MySQL connection is still not working" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "📊 Updated Configuration:" -ForegroundColor Cyan
        Write-Host "========================" -ForegroundColor Cyan
        Write-Host "Database Type: MySQL 8.0" -ForegroundColor White
        Write-Host "Host: 34.63.181.90" -ForegroundColor White
        Write-Host "Port: 3306" -ForegroundColor White
        Write-Host "Database: candidate_hub" -ForegroundColor White
        Write-Host "User: sqlserver" -ForegroundColor White
        Write-Host ""
        Write-Host "🔗 Service URL: $serviceUrl" -ForegroundColor Green
        Write-Host "🏥 Health Check: $serviceUrl/__health" -ForegroundColor Green
        Write-Host "🗄️ Database Status: $serviceUrl/__db-status" -ForegroundColor Green
        
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
Write-Host "⚠️ IMPORTANT NEXT STEPS:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
Write-Host "1. 🔄 Deploy updated code with MySQL configuration (see mysql.ts changes)"
Write-Host "2. 🔑 Verify MySQL user 'sqlserver' exists and has proper permissions"
Write-Host "3. 🌐 Check Cloud SQL authorized networks include Cloud Run IP ranges"
Write-Host "4. 🔍 Monitor logs: gcloud logs tail 'resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME'"
Write-Host ""
Write-Host "🎯 This script has updated the environment variables, but you'll need to deploy" -ForegroundColor Cyan
Write-Host "   the updated code (MySQL instead of SQL Server) for full functionality." -ForegroundColor Cyan
