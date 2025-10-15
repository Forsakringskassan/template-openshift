#!/bin/bash

set -e

eval $(crc oc-env) 2>/dev/null || true

echo "📦 Removing Helm release..."
helm uninstall template-ocp || echo "Release not found, continuing..."

echo "📁 Deleting OpenShift project..."
oc delete project template-ocp 2>/dev/null || echo "Project not found, continuing..."

echo "🛑 Stopping CodeReady Containers..."
crc stop
