#!/bin/bash

set -e

echo "🚀 Setting up OpenShift Local with CodeReady Containers..."

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

echo "🔍 Checking virtualization requirements..."
if ! command -v virtiofsd &> /dev/null; then
    echo "⚠️  virtiofsd not found. Installing qemu-virtiofs..."
    echo "   This requires sudo privileges."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y qemu-system-x86 qemu-utils
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y qemu-kvm qemu-img
    elif command -v yum &> /dev/null; then
        sudo yum install -y qemu-kvm qemu-img
    else
        echo "❌ Unable to install virtiofsd automatically."
        echo "   Please install qemu-system manually for your distribution."
        exit 1
    fi
fi

echo "🔧 Starting CodeReady Containers..."
if ! crc start; then
    echo "⚠️  CRC start failed. Trying certificate renewal..."
    echo "   This is common with older CRC versions."
    
    crc stop 2>/dev/null || true
    sleep 5
    
    if ! crc start; then
        echo "❌ Failed to start CRC after retry."
        echo ""
        echo "🔍 Troubleshooting Certificate Issues:"
        echo "   The certificate renewal failure is common with older CRC versions."
        echo ""
        echo "💡 Solutions to try:"
        echo "   1. UPDATE CRC (Recommended):"
        echo "      Download latest from: https://developers.redhat.com/products/codeready-containers/overview"
        echo ""
        echo "   2. Manual certificate fix:"
        echo "      crc delete --force"
        echo "      crc setup"  
        echo "      crc start"
        echo ""
        echo "   3. Alternative - use Podman Desktop or Docker Desktop with OpenShift extension"
        echo ""
        echo "   4. Use minikube instead (template-kubernetes project)"
        echo ""
        exit 1
    fi
fi

echo "🔐 Setting up OpenShift login..."
eval $(crc oc-env)

if ! oc login -u developer -p developer https://api.crc.testing:6443 --insecure-skip-tls-verify=true; then
    echo ""
    echo "❌ OpenShift cluster is not reachable."
    echo ""
    echo "🔍 Checking cluster status..."
    crc status
    echo ""
    echo "🔧 This is likely due to the certificate renewal issue we saw earlier."
    echo ""
    echo "💡 RECOMMENDED SOLUTION:"
    echo "   Update CodeReady Containers to the latest version (2.55.0):"
    echo "   1. Download from: https://developers.redhat.com/products/codeready-containers/overview"
    echo "   2. Extract and replace your current CRC installation"
    echo "   3. Run: crc delete --force && crc setup && crc start"
    echo ""
    echo "🔄 Alternative - Use the template-kubernetes project instead:"
    echo "   cd ../template-kubernetes && ./deploy.sh"
    echo "   (Works with Minikube and doesn't have certificate issues)"
    echo ""
    exit 1
fi

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