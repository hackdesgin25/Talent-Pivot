# Database connection diagnostics and MySQL user creation
# ===============================================

Write-Host "=== TalentPivot Database Diagnostic ===" -ForegroundColor Green
Write-Host "Checking database connectivity and user setup..." -ForegroundColor Yellow
Write-Host ""

# Test the health endpoints first
Write-Host "1. Testing Backend Health..." -ForegroundColor Cyan
try {
    $healthResponse = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/__health" -Method GET
    Write-Host "   Status: $($healthResponse.status)" -ForegroundColor Green
    Write-Host "   Environment: $($healthResponse.environment)" -ForegroundColor White
    Write-Host "   Database Configured: $($healthResponse.database_configured)" -ForegroundColor White
} catch {
    Write-Host "   Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing Database Connection..." -ForegroundColor Cyan
try {
    $dbResponse = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/__db-status" -Method GET
    Write-Host "   Status: $($dbResponse.status)" -ForegroundColor Green
    Write-Host "   Host: $($dbResponse.database.host)" -ForegroundColor White
    Write-Host "   Port: $($dbResponse.database.port)" -ForegroundColor White
    Write-Host "   Database: $($dbResponse.database.database)" -ForegroundColor White
    Write-Host "   User: $($dbResponse.database.user)" -ForegroundColor White
} catch {
    Write-Host "   Database connection failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Testing User Registration..." -ForegroundColor Cyan
try {
    $body = @{
        full_name = "Diagnostic Test User"
        email = "diagnostic-test@talentpivot.com"
        password = "TestPassword123!"
        role = "HR"
    } | ConvertTo-Json -Depth 3

    $registerResponse = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1/register" -Method POST -Body $body -ContentType "application/json"
    Write-Host "   Registration Successful!" -ForegroundColor Green
    Write-Host "   User: $($registerResponse.user.email)" -ForegroundColor White
} catch {
    $errorMessage = $_.Exception.Message
    Write-Host "   Registration failed: $errorMessage" -ForegroundColor Red
    
    # Parse the error response for specific database issues
    if ($errorMessage -like "*Database service is currently unavailable*") {
        Write-Host "   Issue: MySQL user likely needs to be created" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Magenta
Write-Host "If registration failed:" -ForegroundColor Yellow
Write-Host "1. Open Google Cloud Console: https://console.cloud.google.com/sql/instances" -ForegroundColor White
Write-Host "2. Find your MySQL instance and click on it" -ForegroundColor White
Write-Host "3. Go to 'Users' tab and create user:" -ForegroundColor White
Write-Host "   - Username: sqlserver" -ForegroundColor Cyan
Write-Host "   - Password: TalentPivot@1" -ForegroundColor Cyan
Write-Host "   - Host: % (allow from any IP)" -ForegroundColor Cyan
Write-Host "4. Go to 'Databases' tab and ensure 'candidate_hub' exists" -ForegroundColor White

Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Green
Write-Host "Frontend: https://talentpivot-frontend-z7qlsmuifa-uc.a.run.app" -ForegroundColor White
Write-Host "Backend:  https://talentpivot-backend-z7qlsmuifa-uc.a.run.app" -ForegroundColor White
