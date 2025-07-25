# TalentPivot User Creation Examples
# =================================

Write-Host "Creating Test Users for TalentPivot" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

# Example 1: Create HR User
Write-Host "1. Creating HR User..." -ForegroundColor Cyan
$hrUser = @{
    full_name = "Sarah Johnson"
    email = "sarah.hr@talentpivot.com"
    phone = "5551234567"
    password = "HRPassword123!"
    role = "HR"
} | ConvertTo-Json

Write-Host "Sending HR user creation request..." -ForegroundColor White
try {
    $hrResponse = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1/auth/register" -Method Post -Body $hrUser -ContentType "application/json" -TimeoutSec 30
    Write-Host "✅ HR User Created Successfully!" -ForegroundColor Green
    Write-Host "   Email: sarah.hr@talentpivot.com" -ForegroundColor White
    Write-Host "   Role: HR" -ForegroundColor White
} catch {
    Write-Host "❌ Failed to create HR user" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""

# Example 2: Create Candidate User  
Write-Host "2. Creating Candidate User..." -ForegroundColor Cyan
$candidateUser = @{
    full_name = "Alex Chen"
    email = "alex.candidate@email.com"
    phone = "5559876543"
    experience = 4
    band = "Mid-Level"
    skill = "React, Node.js, TypeScript, MySQL"
    password = "CandidatePass123!"
    role = "candidate"
} | ConvertTo-Json

Write-Host "Sending candidate user creation request..." -ForegroundColor White
try {
    $candidateResponse = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1/auth/register" -Method Post -Body $candidateUser -ContentType "application/json" -TimeoutSec 30
    Write-Host "✅ Candidate User Created Successfully!" -ForegroundColor Green
    Write-Host "   Email: alex.candidate@email.com" -ForegroundColor White
    Write-Host "   Role: candidate" -ForegroundColor White
    Write-Host "   Experience: 4 years" -ForegroundColor White
} catch {
    Write-Host "❌ Failed to create candidate user" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""

# Example 3: Create Another Candidate
Write-Host "3. Creating Senior Candidate..." -ForegroundColor Cyan
$seniorCandidate = @{
    full_name = "Maria Rodriguez"
    email = "maria.senior@email.com"
    phone = "5552345678"
    experience = 8
    band = "Senior"
    skill = "Python, Django, PostgreSQL, AWS, Docker"
    password = "SeniorDev123!"
    role = "candidate"
} | ConvertTo-Json

Write-Host "Sending senior candidate creation request..." -ForegroundColor White
try {
    $seniorResponse = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1/auth/register" -Method Post -Body $seniorCandidate -ContentType "application/json" -TimeoutSec 30
    Write-Host "✅ Senior Candidate Created Successfully!" -ForegroundColor Green
    Write-Host "   Email: maria.senior@email.com" -ForegroundColor White
    Write-Host "   Role: candidate" -ForegroundColor White
    Write-Host "   Experience: 8 years" -ForegroundColor White
} catch {
    Write-Host "❌ Failed to create senior candidate" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 User Creation Process Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Created Users Can Login With:" -ForegroundColor Yellow
Write-Host "• sarah.hr@talentpivot.com (HR)" -ForegroundColor White
Write-Host "• alex.candidate@email.com (Candidate)" -ForegroundColor White  
Write-Host "• maria.senior@email.com (Senior Candidate)" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Login at: https://talentpivot-frontend-z7qlsmuifa-uc.a.run.app" -ForegroundColor Cyan
