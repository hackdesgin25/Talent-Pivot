# Create User API Test Script
# ==========================

Write-Host "TalentPivot User Creation Test" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

# Example 1: Create HR User
Write-Host "Creating HR User..." -ForegroundColor Cyan
$hrUser = @{
    full_name = "John Smith"
    email = "hr.john@company.com"
    phone = "1234567890"
    password = "SecurePassword123"
    role = "HR"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1/auth/register" -Method Post -Body $hrUser -ContentType "application/json"
    Write-Host "HR User Created Successfully!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json)" -ForegroundColor White
} catch {
    Write-Host "Failed to create HR user: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Example 2: Create Candidate User
Write-Host "Creating Candidate User..." -ForegroundColor Cyan
$candidateUser = @{
    full_name = "Jane Doe"
    email = "jane.doe@email.com"
    phone = "9876543210"
    experience = 5
    band = "Senior"
    skill = "JavaScript, React, Node.js"
    password = "CandidatePass123"
    role = "candidate"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1/auth/register" -Method Post -Body $candidateUser -ContentType "application/json"
    Write-Host "Candidate User Created Successfully!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json)" -ForegroundColor White
} catch {
    Write-Host "Failed to create candidate user: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "User Creation Complete!" -ForegroundColor Green
Write-Host "Users can now login using their email and password." -ForegroundColor Yellow
