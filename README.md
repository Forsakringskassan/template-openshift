# Template Kubernetes

This is intended to be used as a template setup when working with other projects.

This will deploy:

- [template-quarkus](https://github.com/Forsakringskassan/template-quarkus)
- [designsystem-user-app](https://github.com/Forsakringskassan/designsystem-user-app)

So that it can be accessed at http://fk-app.local 

Start it with `./deploy.sh`.

Clean it with `./cleanup.sh`.

## Prerequisites

Before running this setup, ensure you have:

1. **Minikube** installed ([Installation Guide](https://minikube.sigs.k8s.io/docs/start/))
2. **Helm** installed ([Installation Guide](https://helm.sh/docs/intro/install/))
3. **kubectl** configured to work with Minikube
4. **Docker** running (required by Minikube)

## Common problems

**Images not pulling**: Ensure you have access to the GitHub Container Registry:
   ```bash
   kubectl create secret docker-registry ghcr-secret \
     --docker-server=ghcr.io \
     --docker-username=<username> \
     --docker-password=<token> \
     --namespace=fk-apps
   ```

**DNS not resolving**: Check that `fk-app.local` is in your `/etc/hosts`:
   ```bash
   grep fk-app.local /etc/hosts
   ```

## Useful Commands

```bash
# Check pod status
kubectl get pods -n fk-apps

# View logs
kubectl logs -f deployment/fk-app-backend -n fk-apps
kubectl logs -f deployment/fk-app-frontend -n fk-apps

# Open Kubernetes dashboard
minikube dashboard
```

## Development and Testing

This template uses the Forsakringskassan reusable Helm CI workflow for continuous integration:

- **Helm Linting**: Validates chart syntax and best practices
- **Chart Templating**: Ensures charts render correctly  
- **Kubernetes Validation**: Validates manifests against Kubernetes API
- **Unit Testing**: Runs Helm unit tests with helm-unittest
- **Security Scanning**: Scans for security issues with Checkov
- **Chart Testing**: Tests installation in Kind cluster (PRs only)

### Running Tests Locally

```bash
# Install Helm unittest plugin
helm plugin install https://github.com/helm-unittest/helm-unittest

# Run unit tests
helm unittest helm-chart/

# Lint the chart
helm lint helm-chart/

# Template and validate
helm template test-release helm-chart/ --debug
```
