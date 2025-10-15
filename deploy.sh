#!/bin/bash

set -e

if ! command -v crc &> /dev/null; then
    echo "❌ CodeReady Containers (CRC) is not installed. Please install it first:"
    echo "   https://developers.redhat.com/products/codeready-containers/overview"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install it first:"
    echo "   https://helm.sh/docs/intro/install/"
    exit 1
fi

if ! command -v oc &> /dev/null; then
    echo "❌ OpenShift CLI (oc) is not installed. Please install it first:"
    echo "   It should be included with CRC installation."
    exit 1
fi

echo "🔧 Starting CodeReady Containers..."
crc start

echo "🔐 Setting up OpenShift login..."
eval $(crc oc-env)

oc login -u developer -p developer https://api.crc.testing:6443 --insecure-skip-tls-verify=true

echo "📁 Creating/switching to project..."
oc new-project template-ocp 2>/dev/null || oc project template-ocp

echo "📦 Deploying FK application stack..."
helm upgrade --install template-ocp ./helm-chart --wait

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
    echo "   Routes:"
    echo
    oc get routes
    echo
fi
echo ""
echo "📊 Open OpenShift web console:"
echo "   crc console"
echo ""