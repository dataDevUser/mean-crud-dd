#!/bin/bash
# vm-setup.sh
# Run this once on a fresh Ubuntu VM to install Docker, Docker Compose, and Nginx

set -e

echo "🚀 Setting up MEAN App VM..."

# Update system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl git nginx

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose plugin
sudo apt-get install -y docker-compose-plugin

# Verify installations
docker --version
docker compose version

# Create app directory
mkdir -p ~/mean-app/nginx

echo "✅ VM setup complete!"
echo "⚠️  Log out and back in for Docker group permissions to take effect."
