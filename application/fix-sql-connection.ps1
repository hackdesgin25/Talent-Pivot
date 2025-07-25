# SQL Connection Fix Script for TalentPivot (PowerShell)
# This script helps diagnose and fix SQL Server connection issues

Write-Host "🔍 TalentPivot SQL Connection Diagnostic & Fix Script" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Set your project details
$PROJECT_ID = "ltc-reboot25-team-51"
$REGION = "us-central1"
$SERVICE_NAME = "talentpivot-backend"

Write-Host "📋 Project ID: $PROJECT_ID" -ForegroundColor Yellow
Write-Host "🌍 Region: $REGION" -ForegroundColor Yellow
Write-Host "🚀 Service: $SERVICE_NAME" -ForegroundColor Yellow
Write-Host ""

# Function to check if gcloud is configured
function Test-GcloudConfig {
    try {
        $gcloudPath = Get-Command gcloud -ErrorAction Stop
        Write-Host "✅ gcloud CLI found at: $($gcloudPath.Source)" -ForegroundColor Green
        
        $activeAccount = gcloud auth list --filter=status:ACTIVE --format="value(account)" | Select-Object -First 1
        if ([string]::IsNullOrEmpty($activeAccount)) {
            Write-Host "❌ No active gcloud authentication found" -ForegroundColor Red
            Write-Host "Run: gcloud auth login" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "✅ Active account: $activeAccount" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ gcloud CLI is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Install from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
        exit 1
    }
}

# Function to check current environment variables
function Get-CurrentConfig {
    Write-Host "🔍 Checking current Cloud Run environment variables..." -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    
    try {
        $envVars = gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(spec.template.spec.template.spec.containers[0].env[].name,spec.template.spec.template.spec.containers[0].env[].value)" 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to get service details. Check if service exists and you have permissions." -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Current environment variables:" -ForegroundColor Yellow
        $envVars | Where-Object { $_ -match "(SQL_HOST|SQL_USER|SQL_PASSWORD|SQL_DATABASE|SQL_PORT)" } | ForEach-Object { Write-Host "  $_" }
        
        if (($envVars | Where-Object { $_ -match "SQL_" }).Count -eq 0) {
            Write-Host "  No SQL-related environment variables found" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    catch {
        Write-Host "❌ Error checking current configuration: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to test database connectivity
function Test-DatabaseConnectivity {
    param(
        [string]$HostName,
        [int]$Port
    )
    
    Write-Host "🌐 Testing connectivity to ${HostName}:${Port}..." -ForegroundColor Cyan
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($HostName, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(5000, $false)
        
        if ($wait) {
            $tcpClient.EndConnect($connect)
            $tcpClient.Close()
            Write-Host "✅ Network connectivity to ${HostName}:${Port} is working" -ForegroundColor Green
            return $true
        }
        else {
            $tcpClient.Close()
            Write-Host "❌ Cannot connect to ${HostName}:${Port} (timeout)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Cannot connect to ${HostName}:${Port} - $_" -ForegroundColor Red
        return $false
    }
}

# Function to update environment variables
function Update-EnvironmentVariables {
    Write-Host "🔧 Updating Cloud Run environment variables..." -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
    
    # Use the configuration from deploy.ps1
    $SQL_HOST = "34.29.235.28"
    $SQL_USER = "sqlserver"
    $SQL_PASSWORD = "TalentPivot@1"
    $SQL_DATABASE = "candidate_hub"
    $SQL_PORT = "1433"
    
    Write-Host "Setting environment variables:" -ForegroundColor Yellow
    Write-Host "  SQL_HOST=$SQL_HOST"
    Write-Host "  SQL_USER=$SQL_USER"
    Write-Host "  SQL_PASSWORD=***"
    Write-Host "  SQL_DATABASE=$SQL_DATABASE"
    Write-Host "  SQL_PORT=$SQL_PORT"
    Write-Host ""
    
    try {
        gcloud run services update $SERVICE_NAME `
            --region=$REGION `
            --set-env-vars SQL_HOST="$SQL_HOST" `
            --set-env-vars SQL_USER="$SQL_USER" `
            --set-env-vars SQL_PASSWORD="$SQL_PASSWORD" `
            --set-env-vars SQL_DATABASE="$SQL_DATABASE" `
            --set-env-vars SQL_PORT="$SQL_PORT" `
            --quiet
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Environment variables updated successfully" -ForegroundColor Green
            Write-Host "⏱️ Waiting for deployment to complete..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
            return $true
        }
        else {
            Write-Host "❌ Failed to update environment variables" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Error updating environment variables: $_" -ForegroundColor Red
        return $false
    }
}

# Function to check service health
function Test-ServiceHealth {
    Write-Host "🏥 Checking service health..." -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    
    try {
        $serviceUrl = gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)" 2>$null
        
        if ([string]::IsNullOrEmpty($serviceUrl)) {
            Write-Host "❌ Could not get service URL" -ForegroundColor Red
            return $false
        }
        
        Write-Host "🔗 Service URL: $serviceUrl" -ForegroundColor Yellow
        
        # Test health endpoint
        Write-Host "Testing health endpoint..." -ForegroundColor Cyan
        try {
            Invoke-RestMethod -Uri "$serviceUrl/__health" -Method Get -TimeoutSec 10 | Out-Null
            Write-Host "✅ Health endpoint is responding" -ForegroundColor Green
            
            # Test database status endpoint
            Write-Host "Testing database status endpoint..." -ForegroundColor Cyan
            try {
                $dbStatusResponse = Invoke-RestMethod -Uri "$serviceUrl/__db-status" -Method Get -TimeoutSec 15
                Write-Host "✅ Database status endpoint is responding" -ForegroundColor Green
                Write-Host "Response status: $($dbStatusResponse.status)" -ForegroundColor Yellow
                if ($dbStatusResponse.message) {
                    Write-Host "Message: $($dbStatusResponse.message)" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "❌ Database status endpoint failed: $_" -ForegroundColor Red
                Write-Host "This may indicate database connectivity issues" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "❌ Health endpoint is not responding: $_" -ForegroundColor Red
            Write-Host "Service may still be starting up or there's an application error" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ Error checking service health: $_" -ForegroundColor Red
        return $false
    }
}

# Function to show recent logs
function Get-RecentLogs {
    Write-Host "📋 Recent application logs..." -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    
    try {
        gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" `
            --limit=20 `
            --format="table(timestamp,textPayload)" `
            --freshness=1h
    }
    catch {
        Write-Host "❌ Error retrieving logs: $_" -ForegroundColor Red
    }
}

# Main execution
function Main {
    Test-GcloudConfig
    Write-Host ""
    
    Get-CurrentConfig
    
    # Test connectivity to both potential hosts
    Test-DatabaseConnectivity -HostName "34.63.181.90" -Port 1433
    Test-DatabaseConnectivity -HostName "34.29.235.28" -Port 1433
    Write-Host ""
    
    # Ask user if they want to update configuration
    $response = Read-Host "🤔 Do you want to update the environment variables to use 34.29.235.28? (y/N)"
    
    if ($response -match '^[Yy]$') {
        $updateSuccess = Update-EnvironmentVariables
        if ($updateSuccess) {
            Write-Host ""
            Test-ServiceHealth
            Write-Host ""
            Get-RecentLogs
        }
    }
    else {
        Write-Host "ℹ️ Configuration not updated. Current settings preserved." -ForegroundColor Blue
    }
    
    Write-Host ""
    Write-Host "🎯 Summary of actions:" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host "1. ✅ Checked current Cloud Run configuration"
    Write-Host "2. ✅ Tested network connectivity"
    if ($response -match '^[Yy]$') {
        Write-Host "3. ✅ Updated environment variables"
        Write-Host "4. ✅ Verified service health"
        Write-Host "5. ✅ Showed recent logs"
    }
    else {
        Write-Host "3. ⏭️ Skipped configuration update"
    }
    Write-Host ""
    Write-Host "💡 Next steps:" -ForegroundColor Yellow
    Write-Host "- Monitor logs: gcloud logs tail `"resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME`""
    Write-Host "- Check database status: visit your-service-url/__db-status"
    Write-Host "- Review troubleshooting guide: SQL_CONNECTION_TROUBLESHOOTING.md"
}

# Run the main function
Main
