# Fix MySQL User Permissions for Cloud Run
# This script helps diagnose and fix the MySQL user access denied error

Write-Host "🔍 MySQL User Permission Diagnostic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "❌ Current Error:" -ForegroundColor Red
Write-Host "   Access denied for user 'sqlserver'@'34.96.47.56' (using password: YES)" -ForegroundColor Red
Write-Host ""

Write-Host "🔍 Problem Analysis:" -ForegroundColor Yellow
Write-Host "   1. Cloud Run service is connecting from IP: 34.96.47.56" -ForegroundColor White
Write-Host "   2. MySQL user 'sqlserver' cannot connect from this IP" -ForegroundColor White
Write-Host "   3. Either password is wrong OR user permissions are restricted" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Solution Options:" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

Write-Host "Option 1: Connect to MySQL and fix user permissions" -ForegroundColor Cyan
Write-Host "---------------------------------------------------" -ForegroundColor Cyan
Write-Host "If you have MySQL admin access, run these commands:" -ForegroundColor White
Write-Host ""
Write-Host "-- Connect to your MySQL instance" -ForegroundColor Gray
Write-Host "mysql -h 34.63.181.90 -u root -p" -ForegroundColor Gray
Write-Host "" 
Write-Host "-- Check current user permissions" -ForegroundColor Gray
Write-Host "SELECT user, host FROM mysql.user WHERE user = 'sqlserver';" -ForegroundColor Gray
Write-Host ""
Write-Host "-- Fix 1: Allow from any host (less secure but works)" -ForegroundColor Gray
Write-Host "CREATE USER 'sqlserver'@'%' IDENTIFIED BY 'TalentPivot@1';" -ForegroundColor Gray
Write-Host "GRANT ALL PRIVILEGES ON candidate_hub.* TO 'sqlserver'@'%';" -ForegroundColor Gray
Write-Host "FLUSH PRIVILEGES;" -ForegroundColor Gray
Write-Host ""
Write-Host "-- Fix 2: Allow from specific Cloud Run subnet (more secure)" -ForegroundColor Gray
Write-Host "CREATE USER 'sqlserver'@'34.96.%' IDENTIFIED BY 'TalentPivot@1';" -ForegroundColor Gray
Write-Host "GRANT ALL PRIVILEGES ON candidate_hub.* TO 'sqlserver'@'34.96.%';" -ForegroundColor Gray
Write-Host "FLUSH PRIVILEGES;" -ForegroundColor Gray
Write-Host ""

Write-Host "Option 2: Update Cloud Run to use different credentials" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Update your deployment to use MySQL root or existing user:" -ForegroundColor White
Write-Host ""
Write-Host "gcloud run services update talentpivot-backend \" -ForegroundColor Gray
Write-Host "  --region=us-central1 \" -ForegroundColor Gray
Write-Host "  --set-env-vars SQL_USER=root \" -ForegroundColor Gray
Write-Host "  --set-env-vars SQL_PASSWORD=your_root_password" -ForegroundColor Gray
Write-Host ""

Write-Host "Option 3: Create new MySQL user via Google Cloud Console" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "1. Go to Google Cloud Console > SQL > Your Instance" -ForegroundColor White
Write-Host "2. Click 'Users' tab" -ForegroundColor White
Write-Host "3. Click 'Add User Account'" -ForegroundColor White
Write-Host "4. Create user: sqlserver with password: TalentPivot@1" -ForegroundColor White
Write-Host "5. Set host to: % (allow from anywhere)" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Quick Fix - Create user via gcloud CLI:" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "# Create MySQL user via Google Cloud CLI" -ForegroundColor Gray
Write-Host "gcloud sql users create sqlserver \" -ForegroundColor Gray
Write-Host "  --instance=YOUR_INSTANCE_NAME \" -ForegroundColor Gray
Write-Host "  --password=TalentPivot@1 \" -ForegroundColor Gray
Write-Host "  --host=%" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 Current Database Configuration:" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host "Host: 34.63.181.90" -ForegroundColor White
Write-Host "Port: 3306" -ForegroundColor White
Write-Host "Database: candidate_hub" -ForegroundColor White
Write-Host "User: sqlserver" -ForegroundColor White
Write-Host "Password: TalentPivot@1" -ForegroundColor White
Write-Host "Cloud Run IP: 34.96.47.56" -ForegroundColor White
Write-Host ""

Write-Host "⚠️ IMPORTANT:" -ForegroundColor Red
Write-Host "============" -ForegroundColor Red
Write-Host "The MySQL user 'sqlserver' needs to be created with permission" -ForegroundColor White
Write-Host "to connect from Cloud Run IPs (34.96.x.x range or % for all)" -ForegroundColor White
