#!/bin/bash
# Migration script from lloyds-reboot to new project

OLD_PROJECT="lloyds-reboot"
NEW_PROJECT="your-new-project-id"

echo "🔄 Migrating TalentPivot from $OLD_PROJECT to $NEW_PROJECT"

# Update Jenkinsfile.cd
sed -i "s/$OLD_PROJECT/$NEW_PROJECT/g" Jenkinsfile.cd

# Update any other configuration files
find . -name "*.md" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.ts" -o -name "*.js" | \
xargs grep -l "$OLD_PROJECT" | \
xargs sed -i "s/$OLD_PROJECT/$NEW_PROJECT/g"

echo "✅ Project ID updated in all files"
echo "📋 Next steps:"
echo "1. Run setup-gcp-apis.sh with your new project ID"
echo "2. Update Jenkins credentials with new service account key"
echo "3. Commit and push changes"
echo "4. Trigger CD pipeline"
