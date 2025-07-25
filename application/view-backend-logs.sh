#!/bin/bash
# TalentPivot Backend Logs Viewer Script
# This script provides various ways to view backend logs including database interactions

echo "🔍 TalentPivot Backend Logs Viewer"
echo "================================="
echo

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found. Please install Google Cloud SDK first."
    echo "📥 Download: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo "📊 Available Log Viewing Options:"
echo "1. Real-time logs (tail -f equivalent)"
echo "2. Recent logs (last 50 entries)"
echo "3. Database-specific logs"
echo "4. Error logs only"
echo "5. All logs from last hour"
echo "6. Custom time range logs"
echo

read -p "Choose an option (1-6): " choice

case $choice in
    1)
        echo "🔄 Streaming real-time logs (Press Ctrl+C to stop)..."
        gcloud logging tail "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend" \
            --project=ltc-reboot25-team-51 \
            --format="table(timestamp,severity,textPayload)"
        ;;
    2)
        echo "📋 Showing recent logs..."
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend" \
            --project=ltc-reboot25-team-51 \
            --limit=50 \
            --format="table(timestamp,severity,textPayload)" \
            --freshness=1d
        ;;
    3)
        echo "🗄️ Showing database-related logs..."
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend AND (textPayload:\"SQL\" OR textPayload:\"database\" OR textPayload:\"mysql\" OR textPayload:\"mssql\")" \
            --project=ltc-reboot25-team-51 \
            --limit=30 \
            --format="table(timestamp,severity,textPayload)" \
            --freshness=1d
        ;;
    4)
        echo "❌ Showing error logs only..."
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend AND severity>=ERROR" \
            --project=ltc-reboot25-team-51 \
            --limit=30 \
            --format="table(timestamp,severity,textPayload)" \
            --freshness=1d
        ;;
    5)
        echo "🕐 Showing logs from last hour..."
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend AND timestamp>=\$(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%SZ')" \
            --project=ltc-reboot25-team-51 \
            --format="table(timestamp,severity,textPayload)"
        ;;
    6)
        echo "📅 Custom time range logs..."
        read -p "Enter start time (YYYY-MM-DDTHH:MM:SSZ): " start_time
        read -p "Enter end time (YYYY-MM-DDTHH:MM:SSZ): " end_time
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend AND timestamp>=\"$start_time\" AND timestamp<=\"$end_time\"" \
            --project=ltc-reboot25-team-51 \
            --format="table(timestamp,severity,textPayload)"
        ;;
    *)
        echo "❌ Invalid option. Please run the script again."
        exit 1
        ;;
esac

echo
echo "💡 Tips:"
echo "- Use option 1 for real-time monitoring"
echo "- Use option 3 to debug database issues"
echo "- Use option 4 to quickly find errors"
echo "- Add more logging to your backend code for better debugging"
