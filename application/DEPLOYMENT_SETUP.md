# TalentPivot CD Pipeline Setup Guide

## 🚀 Jenkins Server Requirements

### Required Software
1. **Docker** - For building container images
2. **Google Cloud SDK** - For deploying to Cloud Run
3. **Node.js & npm** - Already installed ✅

### Installation Commands

#### Install Docker (Ubuntu/CentOS)
```bash
# Ubuntu
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Test Docker
docker --version
```

#### Install Google Cloud SDK
```bash
# Install gcloud
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init

# Or using package manager (Ubuntu)
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
```

## 🔧 GCP Configuration

### 1. Enable Required APIs
Run the setup script:
```bash
./setup-gcp-apis.sh
```

Or manually enable APIs:
```bash
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### 2. Create Service Account
```bash
gcloud iam service-accounts create jenkins-ci \
    --display-name="Jenkins CI/CD Service Account"

gcloud projects add-iam-policy-binding ltc-reboot25-team-51 \
    --member="serviceAccount:jenkins-ci@ltc-reboot25-team-51.iam.gserviceaccount.com" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding ltc-reboot25-team-51 \
    --member="serviceAccount:jenkins-ci@ltc-reboot25-team-51.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding ltc-reboot25-team-51 \
    --member="serviceAccount:jenkins-ci@ltc-reboot25-team-51.iam.gserviceaccount.com" \
    --role="roles/cloudbuild.builds.editor"
```

### 3. Generate Service Account Key
```bash
gcloud iam service-accounts keys create gcp-key.json \
    --iam-account=jenkins-ci@ltc-reboot25-team-51.iam.gserviceaccount.com
```

## 🔑 Jenkins Configuration

### 1. Add GCP Credentials
1. Go to Jenkins → Manage Jenkins → Manage Credentials
2. Add new credential:
   - Kind: Secret file
   - File: Upload `gcp-key.json`
   - ID: `gcp-key`
   - Description: "GCP Service Account Key"

### 2. Add GitHub SSH Key
1. Add credential:
   - Kind: SSH Username with private key
   - ID: `github-jenkins-ssh`
   - Username: `git`
   - Private Key: Your GitHub SSH private key

## 🧪 Testing the Setup

### Test Docker
```bash
docker run hello-world
```

### Test GCP Authentication
```bash
gcloud auth activate-service-account --key-file=gcp-key.json
gcloud config set project ltc-reboot25-team-51
gcloud run services list --region=us-central1
```

### Test Container Registry
```bash
gcloud auth configure-docker
docker tag hello-world gcr.io/ltc-reboot25-team-51/test
docker push gcr.io/ltc-reboot25-team-51/test
```

## 🚦 Pipeline Status

### CI Pipeline (Jenkinsfile.ci)
- ✅ Frontend build and lint
- ✅ Backend build and lint  
- ✅ TypeScript compilation
- ✅ Artifact archiving

### CD Pipeline (Jenkinsfile.cd)
- ⚠️ **Requires Docker installation**
- ⚠️ **Requires GCP authentication setup**
- 🏗️ Frontend Docker build & push
- 🏗️ Backend Docker build & push
- ☁️ Cloud Run deployment

## 📞 Troubleshooting

### Common Issues

1. **"docker: command not found"**
   - Install Docker and restart Jenkins
   - Add jenkins user to docker group

2. **"ACCESS_TOKEN_SCOPE_INSUFFICIENT"**
   - Service account needs proper IAM roles
   - Re-run the setup script

3. **"Cannot connect to the Docker daemon"**
   - Start Docker service: `sudo systemctl start docker`
   - Check jenkins user permissions

4. **Build failures with npm**
   - Clear workspace and retry
   - Check package.json dependencies

### Support Commands
```bash
# Check Docker status
sudo systemctl status docker

# Check Jenkins logs
sudo journalctl -u jenkins -f

# Test GCP connection
gcloud auth list
gcloud config list

# Check container registry
gcloud container images list
```

## 🎯 Next Steps

Once Docker and GCP are properly configured:
1. 🔄 Re-run the CD pipeline
2. 🌐 Access deployed applications via Cloud Run URLs
3. 📊 Monitor deployments in GCP Console
4. 🔧 Configure custom domains and SSL certificates

---
*For additional support, check Jenkins logs and GCP Console for detailed error messages.*
