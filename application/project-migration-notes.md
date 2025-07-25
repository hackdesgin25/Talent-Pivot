# Update these values in your Jenkinsfile.cd after setting up new GCP project

# Old project ID (current)
OLD_PROJECT_ID="lloyds-reboot"

# New project ID (replace with your new project)
NEW_PROJECT_ID="your-new-project-id"

# You'll need to update all occurrences in Jenkinsfile.cd:
# - gcr.io/lloyds-reboot/ → gcr.io/your-new-project-id/
# - gcloud config set project lloyds-reboot → gcloud config set project your-new-project-id
