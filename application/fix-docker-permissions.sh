#!/bin/bash

# Docker Permission Fix for Jenkins
# Run this script on your Jenkins server as root/sudo

echo "🔧 Fixing Docker permissions for Jenkins..."

# Add jenkins user to docker group
echo "Adding jenkins user to docker group..."
sudo usermod -aG docker jenkins

# Check if jenkins user is now in docker group
echo "✅ Jenkins user groups after update:"
groups jenkins

# Restart docker service to ensure permissions are applied
echo "🔄 Restarting Docker service..."
sudo systemctl restart docker

# Check docker service status
echo "📊 Docker service status:"
sudo systemctl status docker --no-pager -l

echo ""
echo "🚀 Next steps:"
echo "1. Restart Jenkins service: sudo systemctl restart jenkins"
echo "2. Or restart Jenkins from the web interface"
echo "3. Wait a few minutes for Jenkins to fully restart"
echo "4. Re-run the CD pipeline"

echo ""
echo "🧪 To test Docker access manually:"
echo "sudo -u jenkins docker --version"
echo "sudo -u jenkins docker run hello-world"

echo ""
echo "✅ Docker permission fix completed!"
echo "Please restart Jenkins service to apply the changes."
