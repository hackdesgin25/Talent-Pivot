# TalentPivot Database User Setup Guide
# =====================================

Write-Host "Creating MySQL User for TalentPivot Application" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

Write-Host "STEP 1: Connect to Google Cloud SQL" -ForegroundColor Cyan
Write-Host "-----------------------------------" -ForegroundColor Cyan
Write-Host "1. Open Google Cloud Console: https://console.cloud.google.com/sql/instances" -ForegroundColor White
Write-Host "2. Find your Cloud SQL instance (MySQL 8.0)" -ForegroundColor White
Write-Host "3. Click on the instance name" -ForegroundColor White
Write-Host ""

Write-Host "STEP 2: Create Database User" -ForegroundColor Cyan
Write-Host "----------------------------" -ForegroundColor Cyan
Write-Host "1. Click 'Users' tab in the left navigation" -ForegroundColor White
Write-Host "2. Click 'Add User Account' button" -ForegroundColor White
Write-Host "3. Fill in the form:" -ForegroundColor White
Write-Host "   Username: sqlserver" -ForegroundColor Yellow
Write-Host "   Password: TalentPivot@1" -ForegroundColor Yellow
Write-Host "   Host: % (this allows connections from any IP)" -ForegroundColor Yellow
Write-Host "4. Click 'Add' to create the user" -ForegroundColor White
Write-Host ""

Write-Host "STEP 3: Verify Database Exists" -ForegroundColor Cyan
Write-Host "------------------------------" -ForegroundColor Cyan
Write-Host "1. Click 'Databases' tab" -ForegroundColor White
Write-Host "2. Ensure 'candidate_hub' database exists" -ForegroundColor White
Write-Host "3. If not, click 'Create Database' and name it 'candidate_hub'" -ForegroundColor White
Write-Host ""

Write-Host "STEP 4: Test Connection" -ForegroundColor Cyan
Write-Host "----------------------" -ForegroundColor Cyan
Write-Host "After creating the user, run this script again to test:" -ForegroundColor White
Write-Host ".\test-db.ps1" -ForegroundColor Yellow
Write-Host ""

Write-Host "Expected Result:" -ForegroundColor Green
Write-Host "- Health endpoint: OK" -ForegroundColor White
Write-Host "- Database status: Connected" -ForegroundColor White
Write-Host "- Application ready for use!" -ForegroundColor White
Write-Host ""

Write-Host "Current Application URLs:" -ForegroundColor Magenta
Write-Host "Frontend: https://talentpivot-frontend-z7qlsmuifa-uc.a.run.app" -ForegroundColor White
Write-Host "Backend: https://talentpivot-backend-z7qlsmuifa-uc.a.run.app" -ForegroundColor White
