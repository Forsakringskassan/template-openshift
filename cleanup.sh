#!/bin/bash

set -e

# Set OpenShift environment
eval $(crc oc-env) 2>/dev/null || true

# Remove the Helm release
echo "📦 Removing Helm release..."
helm uninstall template-ocp || echo "Release not found, continuing..."

# Delete the project
echo "📁 Deleting OpenShift project..."
oc delete project template-ocp 2>/dev/null || echo "Project not found, continuing..."

# Stop CRC
echo "🛑 Stopping CodeReady Containers..."
crc stop
