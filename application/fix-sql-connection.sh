#!/bin/bash

# SQL Connection Fix Script for TalentPivot
# This script helps diagnose and fix SQL Server connection issues

echo "🔍 TalentPivot SQL Connection Diagnostic & Fix Script"
echo "===================================================="

# Set your project details
PROJECT_ID="ltc-reboot25-team-51"
REGION="us-central1"
SERVICE_NAME="talentpivot-backend"

echo "📋 Project ID: $PROJECT_ID"
echo "🌍 Region: $REGION"
echo "🚀 Service: $SERVICE_NAME"
echo ""

# Function to check if gcloud is configured
check_gcloud() {
    if ! command -v gcloud &> /dev/null; then
        echo "❌ gcloud CLI is not installed or not in PATH"
        exit 1
    fi
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 > /dev/null 2>&1; then
        echo "❌ No active gcloud authentication found"
        echo "Run: gcloud auth login"
        exit 1
    fi
    
    echo "✅ gcloud CLI is configured"
}

# Function to check current environment variables
check_current_config() {
    echo "🔍 Checking current Cloud Run environment variables..."
    echo "======================================================"
    
    # Get current environment variables
    ENV_VARS=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(spec.template.spec.template.spec.containers[0].env[].name,spec.template.spec.template.spec.containers[0].env[].value)" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to get service details. Check if service exists and you have permissions."
        exit 1
    fi
    
    echo "Current environment variables:"
    echo "$ENV_VARS" | grep -E "(SQL_HOST|SQL_USER|SQL_PASSWORD|SQL_DATABASE|SQL_PORT)" || echo "No SQL-related environment variables found"
    echo ""
}

# Function to test database connectivity
test_connectivity() {
    local host=$1
    local port=$2
    
    echo "🌐 Testing connectivity to $host:$port..."
    
    # Test using nc (netcat)
    if command -v nc &> /dev/null; then
        if timeout 5 nc -z $host $port 2>/dev/null; then
            echo "✅ Network connectivity to $host:$port is working"
            return 0
        else
            echo "❌ Cannot connect to $host:$port"
            return 1
        fi
    else
        echo "⚠️ netcat (nc) not available, skipping connectivity test"
        return 2
    fi
}

# Function to update environment variables
update_env_vars() {
    echo "🔧 Updating Cloud Run environment variables..."
    echo "=============================================="
    
    # Use the configuration from deploy.ps1
    SQL_HOST="34.29.235.28"
    SQL_USER="sqlserver"
    SQL_PASSWORD="TalentPivot@1"
    SQL_DATABASE="candidate_hub"
    SQL_PORT="1433"
    
    echo "Setting environment variables:"
    echo "  SQL_HOST=$SQL_HOST"
    echo "  SQL_USER=$SQL_USER"
    echo "  SQL_PASSWORD=***"
    echo "  SQL_DATABASE=$SQL_DATABASE"
    echo "  SQL_PORT=$SQL_PORT"
    echo ""
    
    # Update the service
    gcloud run services update $SERVICE_NAME \
        --region=$REGION \
        --set-env-vars SQL_HOST="$SQL_HOST" \
        --set-env-vars SQL_USER="$SQL_USER" \
        --set-env-vars SQL_PASSWORD="$SQL_PASSWORD" \
        --set-env-vars SQL_DATABASE="$SQL_DATABASE" \
        --set-env-vars SQL_PORT="$SQL_PORT" \
        --quiet
    
    if [ $? -eq 0 ]; then
        echo "✅ Environment variables updated successfully"
        echo "⏱️ Waiting for deployment to complete..."
        sleep 10
    else
        echo "❌ Failed to update environment variables"
        exit 1
    fi
}

# Function to check service health
check_service_health() {
    echo "🏥 Checking service health..."
    echo "============================="
    
    # Get service URL
    SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)" 2>/dev/null)
    
    if [ -z "$SERVICE_URL" ]; then
        echo "❌ Could not get service URL"
        return 1
    fi
    
    echo "🔗 Service URL: $SERVICE_URL"
    
    # Test health endpoint
    echo "Testing health endpoint..."
    if curl -s -f "$SERVICE_URL/__health" > /dev/null 2>&1; then
        echo "✅ Health endpoint is responding"
        
        # Test database status endpoint
        echo "Testing database status endpoint..."
        DB_STATUS=$(curl -s "$SERVICE_URL/__db-status" 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            echo "✅ Database status endpoint is responding"
            echo "Response: $DB_STATUS"
        else
            echo "❌ Database status endpoint failed"
            echo "This may indicate database connectivity issues"
        fi
    else
        echo "❌ Health endpoint is not responding"
        echo "Service may still be starting up or there's an application error"
    fi
}

# Function to show recent logs
show_recent_logs() {
    echo "📋 Recent application logs..."
    echo "============================"
    
    gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" \
        --limit=20 \
        --format="table(timestamp,textPayload)" \
        --freshness=1h
}

# Main execution
main() {
    check_gcloud
    echo ""
    
    check_current_config
    
    # Test connectivity to both potential hosts
    test_connectivity "34.63.181.90" "1433"
    test_connectivity "34.29.235.28" "1433"
    echo ""
    
    # Ask user if they want to update configuration
    read -p "🤔 Do you want to update the environment variables to use 34.29.235.28? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        update_env_vars
        echo ""
        check_service_health
        echo ""
        show_recent_logs
    else
        echo "ℹ️ Configuration not updated. Current settings preserved."
    fi
    
    echo ""
    echo "🎯 Summary of actions:"
    echo "======================"
    echo "1. ✅ Checked current Cloud Run configuration"
    echo "2. ✅ Tested network connectivity"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "3. ✅ Updated environment variables"
        echo "4. ✅ Verified service health"
        echo "5. ✅ Showed recent logs"
    else
        echo "3. ⏭️ Skipped configuration update"
    fi
    echo ""
    echo "💡 Next steps:"
    echo "- Monitor logs: gcloud logs tail \"resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME\""
    echo "- Check database status: curl $SERVICE_URL/__db-status"
    echo "- Review troubleshooting guide: SQL_CONNECTION_TROUBLESHOOTING.md"
}

# Run the main function
main
