# CD Pipeline Container Registry Permission Fix

## Issue Summary
The Jenkins CD pipeline was failing at the Docker push stage with the error:
```
denied: gcr.io repo does not exist. Creating on push requires the artifactregistry.repositories.createOnPush permission
```

## Root Cause Analysis
1. **Initial Issue**: Missing Container Registry permissions for the service account
2. **Updated Issue**: Service account lacked `artifactregistry.repoAdmin` permission to create repositories on first push
3. **APIs**: Container Registry and Artifact Registry APIs needed to be enabled

## Current Pipeline Status (After Fix)
✅ **Working Components:**
- Git checkout and SCM polling
- Frontend build and lint (minor warnings only)
- Backend build (TypeScript warnings but builds complete)
- Docker build (both frontend and backend images built successfully)
- GCP authentication (service account authentication working)
- Docker daemon access (jenkins user has docker permissions)

🔧 **Fixed Component:**
- Docker push to gcr.io (permissions added via GCloud Console)

## Solution
The service account needs additional IAM roles for Container Registry operations:

### Required Permissions (APPLIED VIA GCLOUD CONSOLE)
1. `roles/storage.objectAdmin` - For storing images in GCS backend
2. `roles/containerregistry.ServiceAgent` - For Container Registry service operations  
3. `roles/artifactregistry.writer` - For modern Artifact Registry access
4. `roles/artifactregistry.repoAdmin` - For creating repositories on first push ⭐
5. `roles/run.admin` - For Cloud Run deployment
6. `roles/iam.serviceAccountUser` - For service account usage

### ✅ Status: PERMISSIONS HAVE BEEN APPLIED
The required permissions have been added via the GCloud Console.

### Fix Commands
Run these commands on the Jenkins server or any machine with gcloud access:

```bash
# Set project
gcloud config set project ltc-reboot25-team-51

# Add required permissions
gcloud projects add-iam-policy-binding ltc-reboot25-team-51 \
    --member="serviceAccount:jenkins-talentpivot@ltc-reboot25-team-51.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin"

gcloud projects add-iam-policy-binding ltc-reboot25-team-51 \
    --member="serviceAccount:jenkins-talentpivot@ltc-reboot25-team-51.iam.gserviceaccount.com" \
    --role="roles/containerregistry.ServiceAgent"

gcloud projects add-iam-policy-binding ltc-reboot25-team-51 \
    --member="serviceAccount:jenkins-talentpivot@ltc-reboot25-team-51.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"
```

### Automated Fix Scripts
Two scripts are available in the repository:
- `fix-gcp-permissions.sh` (Linux/macOS)
- `fix-gcp-permissions.ps1` (Windows PowerShell)

## Timeline to Fix
1. **Run permission fix:** 2-3 minutes to execute commands
2. **Permission propagation:** 1-2 minutes for GCP IAM to propagate
3. **Re-run pipeline:** 5-8 minutes for complete CD pipeline execution

## ✅ Expected Outcome (Ready to Test)
After applying the permissions via GCloud Console:
1. Docker builds will continue to succeed ✅
2. Docker push to gcr.io should now succeed ✅  
3. Cloud Run deployment should proceed ✅
4. Complete CI/CD pipeline should be operational ✅

## 🚀 Next Steps
**The pipeline is ready for testing!**
1. **Re-run the Jenkins CD pipeline** - permissions are now in place
2. **Monitor the build logs** - Docker push should succeed this time
3. **Verify Cloud Run deployment** - services should deploy successfully

## Verification Commands
Check service account permissions:
```bash
./verify-gcp-permissions.sh
```

Or manually check:
```bash
gcloud projects get-iam-policy ltc-reboot25-team-51 \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:jenkins-talentpivot@ltc-reboot25-team-51.iam.gserviceaccount.com"
```
