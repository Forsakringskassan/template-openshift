#!/bin/bash

# FK Kubernetes Stack Cleanup Script
# This script removes the FK application stack and optionally stops Minikube

set -e

echo "🧹 Cleaning up FK Kubernetes Stack..."

# Remove the Helm release
echo "📦 Removing Helm release..."
helm uninstall template-k8s || echo "Release not found, continuing..."

# Remove from /etc/hosts
echo "📝 Removing entry from /etc/hosts..."
echo "You may need to enter your password to modify /etc/hosts"
sudo sed -i '/fk-app.local/d' /etc/hosts 2>/dev/null || true

# Ask if user wants to stop minikube
read -p "Do you want to stop Minikube? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🛑 Stopping Minikube..."
    minikube stop
fi

echo "✅ Cleanup completed!"