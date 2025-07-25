Write-Host "🔍 MySQL User Permission Diagnostic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "❌ Current Error:" -ForegroundColor Red
Write-Host "   Access denied for user sqlserver from 34.96.47.56" -ForegroundColor Red
Write-Host ""

Write-Host "🔍 Problem Analysis:" -ForegroundColor Yellow
Write-Host "   1. Cloud Run service is connecting from IP: 34.96.47.56" -ForegroundColor White
Write-Host "   2. MySQL user 'sqlserver' cannot connect from this IP" -ForegroundColor White
Write-Host "   3. Either password is wrong OR user permissions are restricted" -ForegroundColor White
Write-Host ""

Write-Host "🔧 RECOMMENDED SOLUTION:" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""
Write-Host "Create MySQL user via Google Cloud Console:" -ForegroundColor Cyan
Write-Host "1. Go to: https://console.cloud.google.com/sql" -ForegroundColor White
Write-Host "2. Select your Cloud SQL instance" -ForegroundColor White
Write-Host "3. Click 'Users' tab" -ForegroundColor White
Write-Host "4. Click 'Add User Account'" -ForegroundColor White
Write-Host "5. Enter:" -ForegroundColor White
Write-Host "   - Username: sqlserver" -ForegroundColor Gray
Write-Host "   - Password: TalentPivot@1" -ForegroundColor Gray
Write-Host "   - Host: % (allow from anywhere)" -ForegroundColor Gray
Write-Host "6. Click 'Add'" -ForegroundColor White
Write-Host ""

Write-Host "📋 Current Configuration:" -ForegroundColor Yellow
Write-Host "Host: 34.63.181.90" -ForegroundColor White
Write-Host "Port: 3306" -ForegroundColor White
Write-Host "Database: candidate_hub" -ForegroundColor White
Write-Host "User: sqlserver" -ForegroundColor White
Write-Host "Cloud Run IP: 34.96.47.56" -ForegroundColor White
Write-Host ""

Write-Host "⚠️ The user 'sqlserver' needs to be created in your MySQL instance!" -ForegroundColor Red
