# App Store Management

Administrator guide for managing the developer app store.

## Overview

The app store provides a curated catalog of developer tools that are security vetted, version controlled, and highly configurable.

## Catalog Structure

`packages/organization/app-store/catalog.yml` defines available applications:

```yaml
apps:
  docker:
    name: Docker
    description: Container platform
    category: containers
    default_version: "24.0"
  kubectl:
    name: Kubernetes CLI
    description: Kubernetes command-line tool
    category: kubernetes
    default_version: "1.28"
```

## Adding New Applications

### 1. Create Ansible Role

```bash
mkdir -p shared/ansible/roles/app-myapp/{tasks,defaults,templates}
```

### 2. Define Installation Logic

`shared/ansible/roles/app-myapp/tasks/main.yml`:

```yaml
---

- name: Install MyApp
  ansible.builtin.package:
    name: myapp
    state: present
  when: apps.myapp.enabled | default(false)
```

### 3. Add to Catalog

Update `catalog.yml`:

```yaml
myapp:
  name: MyApp
  description: Description here
  category: tools
  default_version: "1.0.0"
```

### 4. Add Configuration

Update `packages/organization/ansible/group_vars/apps.yml`:

```yaml
myapp:
  enabled: false
  version: "1.0.0"
  config:
    option1: value1
```

### 5. Test

```bash
make test-org
```

## Removing Applications

1. Mark as deprecated in catalog
2. Update documentation
3. Notify users
4. Remove after grace period

## Updating Versions

1. Test new version thoroughly
2. Update default version in catalog
3. Document breaking changes
4. Communicate to users

## Security Vetting

All apps must pass:

- Security scan
- License review
- Vulnerability check
- Configuration review

## See Also

- [App Store Guide](../app-store.md)
- [FOSS Package Management](foss-packages.md)
