#!/bin/bash

set -e

# Check if crc is installed
if ! command -v crc &> /dev/null; then
    echo "❌ CodeReady Containers (CRC) is not installed. Please install it first:"
    echo "   https://developers.redhat.com/products/codeready-containers/overview"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install it first:"
    echo "   https://helm.sh/docs/intro/install/"
    exit 1
fi

# Check if oc is installed
if ! command -v oc &> /dev/null; then
    echo "❌ OpenShift CLI (oc) is not installed. Please install it first:"
    echo "   It should be included with CRC installation."
    exit 1
fi

# Start CRC if not running
echo "🔧 Starting CodeReady Containers..."
crc start

# Login to CRC
echo "🔐 Setting up OpenShift login..."
eval $(crc oc-env)

# Login as developer user
oc login -u developer -p developer https://api.crc.testing:6443 --insecure-skip-tls-verify=true

# Create project if it doesn't exist
echo "📁 Creating/switching to project..."
oc new-project template-ocp 2>/dev/null || oc project template-ocp

# Deploy the application using Helm
echo "📦 Deploying FK application stack..."
helm upgrade --install template-ocp ./helm-chart --wait

# Get the route information
echo "� Getting route information..."
ROUTE_HOST=$(oc get route template-ocp-route -o jsonpath='{.spec.host}' 2>/dev/null || echo "Route not found")

echo ""
echo "✅ Deployment completed!"
echo ""
echo "🌍 Your applications are available at:"
echo ""
if [ "$ROUTE_HOST" != "Route not found" ]; then
    echo "   http://$ROUTE_HOST/"
else
    echo "   Check routes with: oc get routes"
fi
echo ""
echo "📊 Open OpenShift web console:"
echo "   crc console"
echo ""