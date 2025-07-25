# TalentPivot Backend Logs Viewer (PowerShell)
# This script provides various ways to view backend logs including database interactions

Write-Host "🔍 TalentPivot Backend Logs Viewer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if gcloud is installed
if (!(Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "❌ gcloud CLI not found. Please install Google Cloud SDK first." -ForegroundColor Red
    Write-Host "📥 Download: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    exit 1
}

Write-Host "📊 Available Log Viewing Options:" -ForegroundColor Green
Write-Host "1. Real-time logs (tail -f equivalent)"
Write-Host "2. Recent logs (last 50 entries)"
Write-Host "3. Database-specific logs"
Write-Host "4. Error logs only"
Write-Host "5. All logs from last hour"
Write-Host "6. Custom time range logs"
Write-Host ""

$choice = Read-Host "Choose an option (1-6)"

switch ($choice) {
    "1" {
        Write-Host "🔄 Streaming real-time logs (Press Ctrl+C to stop)..." -ForegroundColor Yellow
        gcloud logging tail "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend" `
            --project=ltc-reboot25-team-51 `
            --format="table(timestamp,severity,textPayload)"
    }
    "2" {
        Write-Host "📋 Showing recent logs..." -ForegroundColor Yellow
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend" `
            --project=ltc-reboot25-team-51 `
            --limit=50 `
            --format="table(timestamp,severity,textPayload)" `
            --freshness=1d
    }
    "3" {
        Write-Host "🗄️ Showing database-related logs..." -ForegroundColor Yellow
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend AND (textPayload:`"SQL`" OR textPayload:`"database`" OR textPayload:`"mysql`" OR textPayload:`"mssql`")" `
            --project=ltc-reboot25-team-51 `
            --limit=30 `
            --format="table(timestamp,severity,textPayload)" `
            --freshness=1d
    }
    "4" {
        Write-Host "❌ Showing error logs only..." -ForegroundColor Red
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend AND severity>=ERROR" `
            --project=ltc-reboot25-team-51 `
            --limit=30 `
            --format="table(timestamp,severity,textPayload)" `
            --freshness=1d
    }
    "5" {
        Write-Host "🕐 Showing logs from last hour..." -ForegroundColor Yellow
        $oneHourAgo = (Get-Date).AddHours(-1).ToString("yyyy-MM-ddTHH:mm:ssZ")
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend AND timestamp>=`"$oneHourAgo`"" `
            --project=ltc-reboot25-team-51 `
            --format="table(timestamp,severity,textPayload)"
    }
    "6" {
        Write-Host "📅 Custom time range logs..." -ForegroundColor Yellow
        $startTime = Read-Host "Enter start time (YYYY-MM-DDTHH:MM:SSZ)"
        $endTime = Read-Host "Enter end time (YYYY-MM-DDTHH:MM:SSZ)"
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend AND timestamp>=`"$startTime`" AND timestamp<=`"$endTime`"" `
            --project=ltc-reboot25-team-51 `
            --format="table(timestamp,severity,textPayload)"
    }
    default {
        Write-Host "❌ Invalid option. Please run the script again." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Cyan
Write-Host "- Use option 1 for real-time monitoring"
Write-Host "- Use option 3 to debug database issues"
Write-Host "- Use option 4 to quickly find errors"
Write-Host "- Add more logging to your backend code for better debugging"
