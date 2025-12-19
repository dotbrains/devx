# App Store Guide

Learn about the App Store and available developer tools.

## Overview

The App Store provides a curated catalog of developer tools that are:

- Security vetted
- Version controlled
- Highly configurable
- Independently installable

## Available Applications

See `packages/organization/app-store/catalog.yml` for the complete list.

### Core Tools
- Docker
- Kubernetes (kubectl, helm, k9s, k3s)
- Python
- Node.js
- Git

## Enabling Applications

Edit `packages/organization/ansible/group_vars/apps.yml` or your program's configuration.

## Configuration

Apps are configured through YAML files in the Ansible `group_vars` directory.

### Configuration Files

**Organization Level:**

- `packages/organization/ansible/group_vars/apps.yml` - Default apps for all programs

**Program Level:**

- `packages/programs/*/ansible/group_vars/all.yml` - Override organization defaults

### Basic Structure

Each app follows this configuration pattern:

```yaml
org_apps_to_install:
  - name: app-name
    role: app-role-name
    enabled: true
    config:
      version: "X.Y"
      # App-specific options
```

### Configuration Examples

**Docker:**

```yaml
- name: docker
  role: app-docker
  enabled: true
  config:
    version: "24.0"
    compose: true
    buildx: true
    daemon_json:
      log-driver: "json-file"
      log-opts:
        max-size: "10m"
        max-file: "3"
```

**Python:**

```yaml
- name: python
  role: app-python
  enabled: true
  config:
    version: "3.11"
    pip_packages:
      - pytest
      - black
      - pylint
    virtualenv_wrapper: true
```

**Kubernetes Tools:**

```yaml
- name: kubectl
  role: app-kubectl
  enabled: true
  config:
    version: "1.28"
    krew_plugins:
      - ctx
      - ns

- name: helm
  role: app-helm
  enabled: true
  config:
    version: "3.13"
    repos:
      - name: bitnami
        url: "https://charts.bitnami.com/bitnami"
```

**Node.js:**

```yaml
- name: nodejs
  role: app-nodejs
  enabled: true
  config:
    version: "20"
    npm_packages:
      - yarn
      - typescript
      - eslint
```

### Overriding Configurations

**Program-Level Overrides:**

In your program's `all.yml`, override organization settings:

```yaml
# Override app versions
app_nodejs_version: "20.10.0"
app_docker_version: "24.0.7"

# Add program-specific apps
program_apps_to_install:
  - name: postgresql
    role: app-postgresql
    enabled: true
    config:
      version: "15"
      databases:
        - name: "myapp_dev"
          owner: "myapp_user"
  
  - name: redis
    role: app-redis
    enabled: true
    config:
      version: "7.2"
      maxmemory: "256mb"
```

### Disabling Apps

Set `enabled: false` to skip installation:

```yaml
- name: k3s
  role: app-k3s
  enabled: false  # Not needed for this environment
```

### Available Configuration Options

Each app's configurable options are listed in:

- `packages/organization/app-store/catalog.yml` - Catalog metadata
- `packages/organization/ansible/group_vars/apps.yml` - Full examples

### Common Patterns

**Version Pinning:**

```yaml
config:
  version: "1.2.3"  # Specific version
  version: "1.2"    # Minor version
  version: "latest" # Latest stable
```

**Global vs. App-Specific Variables:**

```yaml
# Global override (affects all Docker installations)
app_docker_rootless: true

# App-specific (only for this instance)
- name: docker
  config:
    rootless: true
```

### Configuration Precedence

Configurations are merged in this order:

1. **Base** - System defaults
2. **Organization** - `packages/organization/ansible/group_vars/apps.yml`
3. **Program** - `packages/programs/*/ansible/group_vars/all.yml`

Higher levels override lower levels.
