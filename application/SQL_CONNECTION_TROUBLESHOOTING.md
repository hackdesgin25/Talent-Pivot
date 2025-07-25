# SQL Server Connection Troubleshooting Guide

## Issue Summary
Your application is failing to connect to the SQL Server with the error:
```
❌ SQL Server Connection Failed ConnectionError: Failed to connect to 34.63.181.90:1433 in 15000ms
```

## Analysis

### 1. Configuration Mismatch
- **Error shows**: Connection attempt to `34.63.181.90:1433`
- **deploy.ps1 configures**: `SQL_HOST="34.29.235.28"`
- **Jenkinsfile.cd configures**: `SQL_HOST="34.29.235.28"`

This indicates there's a mismatch between your deployment scripts and the actual runtime environment.

### 2. Possible Causes
1. **Environment Variable Override**: Cloud Run may have environment variables set from a previous deployment
2. **Multiple Deployment Sources**: Different deployment pipelines may be setting different values
3. **Cached Configuration**: Old configuration might be cached in the Cloud Run service
4. **Manual Override**: Someone may have manually updated the environment variables in GCP Console

## Immediate Solutions

### Step 1: Check Current Cloud Run Environment Variables
```bash
gcloud run services describe talentpivot-backend --region=us-central1 --format="value(spec.template.spec.template.spec.containers[0].env[].name,spec.template.spec.template.spec.containers[0].env[].value)"
```

### Step 2: Update Cloud Run Environment Variables
```bash
# Replace with your correct values
gcloud run services update talentpivot-backend \
  --region=us-central1 \
  --set-env-vars SQL_HOST="34.29.235.28" \
  --set-env-vars SQL_USER="sqlserver" \
  --set-env-vars SQL_PASSWORD="TalentPivot@1" \
  --set-env-vars SQL_DATABASE="candidate_hub" \
  --set-env-vars SQL_PORT=1433
```

### Step 3: Force New Deployment
```bash
# Use your deploy script to ensure consistent configuration
./deploy.ps1
```

### Step 4: Verify Database Server Accessibility
Test if the SQL Server is reachable:
```bash
# Test connectivity to the configured server
gcloud compute ssh <any-vm-instance> --zone=<zone> --command="nc -zv 34.29.235.28 1433"

# Or test from Cloud Shell
nc -zv 34.29.235.28 1433
```

## Database Server Investigation

### Check SQL Server Status
1. **Verify Cloud SQL Instance**:
   ```bash
   gcloud sql instances list
   gcloud sql instances describe <instance-name>
   ```

2. **Check Instance IP**:
   - Verify if `34.63.181.90` or `34.29.235.28` is the correct IP
   - Check if the IP has changed recently

3. **Authorized Networks**:
   ```bash
   gcloud sql instances describe <instance-name> --format="value(settings.ipConfiguration.authorizedNetworks[].value)"
   ```

### Firewall Rules
Ensure Cloud Run can reach the SQL Server:
```bash
# Check existing firewall rules
gcloud compute firewall-rules list --filter="direction:INGRESS AND allowed.ports:1433"

# Create rule if needed (adjust source ranges as needed)
gcloud compute firewall-rules create allow-sql-server \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:1433 \
  --source-ranges=0.0.0.0/0
```

## Enhanced Debugging

### 1. Use the New Database Status Endpoint
Once deployed, check:
```
https://your-backend-url/__db-status
```
This will show current environment variables and test the connection.

### 2. Check Application Logs
```bash
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend" --limit=50 --format="table(timestamp,textPayload)"
```

### 3. Real-time Log Monitoring
```bash
gcloud logs tail "resource.type=cloud_run_revision AND resource.labels.service_name=talentpivot-backend"
```

## Configuration Verification

### Current Deployment Scripts Configuration
- **deploy.ps1**: `SQL_HOST="34.29.235.28"`
- **Jenkinsfile.cd**: `SQL_HOST="34.29.235.28"`
- **Backend .env.production**: `SQL_HOST="203.123.45.67"`

### Recommendation
1. **Standardize Configuration**: Ensure all deployment scripts use the same values
2. **Use Cloud Secret Manager**: Store sensitive data like database credentials securely
3. **Environment-specific Config**: Use different configs for dev/staging/production

## Security Best Practices

### 1. Use Cloud SQL Proxy
For better security, consider using Cloud SQL Proxy:
```yaml
# In your Cloud Run service configuration
containers:
- image: gcr.io/your-project/your-app
  env:
  - name: DB_HOST
    value: "127.0.0.1"
  - name: DB_PORT
    value: "5432"
- image: gcr.io/cloudsql-docker/gce-proxy:1.33.2
  args:
  - "/cloud_sql_proxy"
  - "-instances=your-project:region:instance=tcp:5432"
```

### 2. Use Secret Manager
```bash
# Store database password in Secret Manager
echo -n "TalentPivot@1" | gcloud secrets create sql-password --data-file=-

# Update Cloud Run to use secret
gcloud run services update talentpivot-backend \
  --region=us-central1 \
  --set-env-vars SQL_PASSWORD="$(gcloud secrets versions access latest --secret=sql-password)"
```

## Next Steps
1. ✅ Check current Cloud Run environment variables
2. ✅ Update configuration to use consistent IP address
3. ✅ Verify database server accessibility
4. ✅ Test using the `/__db-status` endpoint
5. ✅ Monitor logs for successful connection
6. ✅ Consider implementing Cloud SQL Proxy for security

## Contact Information
If issues persist:
- Check Cloud SQL instance status in GCP Console
- Verify network connectivity from Cloud Run to SQL Server
- Review firewall rules and authorized networks
- Contact your database administrator for server status
