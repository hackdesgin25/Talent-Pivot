Write-Host "🔍 TalentPivot Database Connection Troubleshooting" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Current Status Analysis:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Testing Health Endpoint..." -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/__health" -Method Get -TimeoutSec 10
    Write-Host "   Health Status: $($health.status)" -ForegroundColor Green
    Write-Host "   Environment: $($health.environment)" -ForegroundColor White
    Write-Host "   Database Configured: $($health.database_configured)" -ForegroundColor White
} catch {
    Write-Host "   Health endpoint failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing Database Connection..." -ForegroundColor Cyan
try {
    $dbStatus = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/__db-status" -Method Get -TimeoutSec 15 -ErrorAction Stop
    Write-Host "   Database Status: $($dbStatus.status)" -ForegroundColor Green
    Write-Host "   Host: $($dbStatus.database.host):$($dbStatus.database.port)" -ForegroundColor White
    Write-Host "   User: $($dbStatus.database.user)" -ForegroundColor White
} catch {
    Write-Host "   Database connection failed" -ForegroundColor Red
    Write-Host "   Error: Database pool not initialized" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔧 RECOMMENDED SOLUTIONS:" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""
Write-Host "The 'Database pool not initialized' error suggests:" -ForegroundColor Yellow
Write-Host "1. MySQL user 'sqlserver' doesn't exist OR" -ForegroundColor White
Write-Host "2. User 'sqlserver' can't connect from Cloud Run IPs OR" -ForegroundColor White
Write-Host "3. Password is incorrect OR" -ForegroundColor White
Write-Host "4. Database 'candidate_hub' doesn't exist" -ForegroundColor White
Write-Host ""

Write-Host "✅ SOLUTION: Create MySQL user via Google Cloud Console" -ForegroundColor Green
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "1. Go to: https://console.cloud.google.com/sql/instances" -ForegroundColor White
Write-Host "2. Click on your Cloud SQL instance" -ForegroundColor White
Write-Host "3. Go to Users tab" -ForegroundColor White
Write-Host "4. Click Add User Account" -ForegroundColor White
Write-Host "5. Fill in:" -ForegroundColor White
Write-Host "   - Username: sqlserver" -ForegroundColor Gray
Write-Host "   - Password: TalentPivot@1" -ForegroundColor Gray
Write-Host "   - Host: % (allow from any host)" -ForegroundColor Gray
Write-Host "6. Click Add" -ForegroundColor White
Write-Host ""

Write-Host "📊 Current Configuration:" -ForegroundColor Yellow
Write-Host "Host: 34.63.181.90:3306" -ForegroundColor White
Write-Host "Database: candidate_hub" -ForegroundColor White
Write-Host "User: sqlserver" -ForegroundColor White
Write-Host "Password: TalentPivot@1" -ForegroundColor White
Write-Host ""

Write-Host "After creating the user, the application should work automatically!" -ForegroundColor Green
