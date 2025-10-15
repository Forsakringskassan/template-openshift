# Template Openshift

This is intended to be used as a template local OpenShift setup using Red Hat CodeReady Containers (CRC).

This will deploy:

- [template-quarkus](https://github.com/Forsakringskassan/template-quarkus)
- [designsystem-user-app](https://github.com/Forsakringskassan/designsystem-user-app)

So that it can be accessed on localhost through OpenShift routes.

Start it with `./deploy.sh`.

Clean it with `./cleanup.sh`.

## Prerequisites

### 1. CodeReady Containers (CRC)

Download and install CRC from [Red Hat Developers](https://developers.redhat.com/products/codeready-containers/overview).

**Setup:**

```bash
crc config set pull-secret-file /path/to/pull-secret.txt
crc config set cpus 4
crc config set memory 16384
crc config set disk-size 120
crc setup
```

### 2. Helm 3

Install from [helm.sh](https://helm.sh/docs/intro/install/):

**Linux:**

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 3. OpenShift CLI (oc)

The `oc` CLI is included with CRC installation. You can also download it separately from [OpenShift CLI tools](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html).

### View Application Status

Check pod status

```bash
oc get pods
```

View application logs

```bash
oc logs -f deployment/template-ocp-quarkus
oc logs -f deployment/template-ocp-apache
```

Open OpenShift web console:

```sh
crc console
```

Access the application:

```sh
crc console --url
```

### Authentication Issues

```bash
oc login -u developer -p developer https://api.crc.testing:6443 --insecure-skip-tls-verify=true
oc project template-ocp
```
