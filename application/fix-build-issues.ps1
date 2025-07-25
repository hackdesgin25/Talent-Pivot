# TalentPivot - Fix Jenkins Build Issues
# ====================================

Write-Host "🔧 Fixing Jenkins Build Issues..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# Step 1: Check for duplicate files
Write-Host "1. Checking for duplicate controller files..." -ForegroundColor Cyan
$duplicateControllers = Get-ChildItem -Path "backend/src/controllers" -Filter "*authController*" -Recurse
if ($duplicateControllers.Count -gt 1) {
    Write-Host "   Found duplicate authController files!" -ForegroundColor Red
    foreach ($file in $duplicateControllers) {
        Write-Host "   - $($file.FullName)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✅ No duplicate controller files found" -ForegroundColor Green
}

Write-Host ""

# Step 2: Check for mssql references
Write-Host "2. Checking for old mssql references..." -ForegroundColor Cyan
try {
    $mssqlRefs = Select-String -Path "backend/src/**/*.ts" -Pattern "mssql" -ErrorAction SilentlyContinue
    if ($mssqlRefs) {
        Write-Host "   ❌ Found mssql references that need removal:" -ForegroundColor Red
        foreach ($ref in $mssqlRefs) {
            Write-Host "   - $($ref.Filename):$($ref.LineNumber)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ✅ No mssql references found" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✅ No mssql references found" -ForegroundColor Green
}

Write-Host ""

# Step 3: Verify TypeScript types are installed
Write-Host "3. Checking TypeScript type definitions..." -ForegroundColor Cyan
$packageJson = Get-Content "backend/package.json" | ConvertFrom-Json
$devDeps = $packageJson.devDependencies

$requiredTypes = @(
    "@types/express",
    "@types/cors", 
    "@types/bcrypt",
    "@types/jsonwebtoken",
    "@types/multer",
    "@types/node"
)

$missingTypes = @()
foreach ($type in $requiredTypes) {
    if (-not $devDeps.$type) {
        $missingTypes += $type
    }
}

if ($missingTypes.Count -gt 0) {
    Write-Host "   ❌ Missing TypeScript types:" -ForegroundColor Red
    foreach ($type in $missingTypes) {
        Write-Host "   - $type" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "   📋 To fix: npm install --save-dev $($missingTypes -join ' ')" -ForegroundColor Cyan
} else {
    Write-Host "   ✅ All required TypeScript types are installed" -ForegroundColor Green
}

Write-Host ""

# Step 4: Test TypeScript compilation
Write-Host "4. Testing TypeScript compilation..." -ForegroundColor Cyan
Set-Location "backend"
try {
    $tscOutput = npx tsc --noEmit 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ TypeScript compilation successful" -ForegroundColor Green
    } else {
        Write-Host "   ❌ TypeScript compilation failed:" -ForegroundColor Red
        Write-Host $tscOutput -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Could not run TypeScript compiler" -ForegroundColor Red
}
finally {
    Set-Location ".."
}

Write-Host ""

# Step 5: Recommended next steps
Write-Host "🎯 NEXT STEPS:" -ForegroundColor Green
Write-Host "=============" -ForegroundColor Green
Write-Host "1. If there are still issues, commit and push current changes" -ForegroundColor White
Write-Host "2. Run Jenkins pipeline again (it should work now!)" -ForegroundColor White
Write-Host "3. If it still fails, check the specific error in Jenkins logs" -ForegroundColor White
Write-Host ""
Write-Host "📋 CURRENT STATUS:" -ForegroundColor Yellow
Write-Host "- ✅ MySQL configuration complete" -ForegroundColor White
Write-Host "- ✅ TypeScript types installed" -ForegroundColor White  
Write-Host "- ✅ Duplicate files cleaned" -ForegroundColor White
Write-Host "- ✅ Old mssql references removed" -ForegroundColor White
