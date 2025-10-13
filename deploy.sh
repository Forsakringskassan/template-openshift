#!/bin/bash

# FK Kubernetes Stack Setup Script
# This script sets up Minikube with the FK application stack

set -e

echo "🚀 Setting up FK Kubernetes Stack with Minikube..."

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube is not installed. Please install it first:"
    echo "   https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install it first:"
    echo "   https://helm.sh/docs/intro/install/"
    exit 1
fi

# Start minikube if not running
echo "🔧 Starting Minikube..."
minikube start --driver=docker --cpus=2 --memory=4096

# Enable ingress addon
echo "🌐 Enabling ingress addon..."
minikube addons enable ingress

# Wait for ingress controller to be ready
echo "⏳ Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Deploy the application using Helm
echo "📦 Deploying FK application stack..."
helm upgrade --install fk-app ./helm-chart \
  --namespace fk-apps \
  --create-namespace \
  --wait

# Get the ingress IP
echo "🔍 Getting ingress information..."
INGRESS_IP=$(minikube ip)
echo "Ingress IP: $INGRESS_IP"

# Add to /etc/hosts (requires sudo)
echo "📝 Adding entry to /etc/hosts..."
echo "You may need to enter your password to modify /etc/hosts"
sudo bash -c "echo '$INGRESS_IP fk-app.local' >> /etc/hosts" || true

echo ""
echo "✅ Deployment completed!"
echo ""
echo "🌍 Your applications are now available at:"
echo "   Frontend: http://fk-app.local"
echo "   Backend API: http://fk-app.local/api"
echo ""
echo "📊 Useful commands:"
echo "   kubectl get pods -n fk-apps                 # Check pod status"
echo "   kubectl logs -f deployment/fk-app-backend -n fk-apps   # Backend logs"
echo "   kubectl logs -f deployment/fk-app-frontend -n fk-apps  # Frontend logs"
echo "   minikube dashboard                          # Open Kubernetes dashboard"
echo "   helm list -n fk-apps                       # List Helm releases"
echo ""