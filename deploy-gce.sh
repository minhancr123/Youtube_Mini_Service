#!/bin/bash

# GCE Deployment Script for Mini Service
# This script sets up the application on a GCE VM

echo "🚀 Starting GCE deployment..."

# Update system
sudo apt-get update

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Clone repository (replace with your actual repo URL)
if [ ! -d "Mini_Service" ]; then
    echo "Cloning repository..."
    git clone https://github.com/YOUR_USERNAME/Mini_Service.git
fi

cd Mini_Service

# Build and run with Docker Compose
echo "Building and starting application..."
docker-compose up --build -d

# Check if service is running
echo "Waiting for service to start..."
sleep 10

# Test the service
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Service is running successfully on port 8080!"
else
    echo "⚠️  Service might be starting up. Check logs with: docker-compose logs"
fi

echo "🎉 Deployment complete!"
echo "📝 Don't forget to configure firewall rules:"
echo "   gcloud compute firewall-rules create allow-mini-service --allow tcp:8080 --source-ranges 0.0.0.0/0"
