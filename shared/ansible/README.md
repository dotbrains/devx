# Shared Ansible Resources

Common Ansible roles, modules, and utilities used across all layers.

## Directory Structure

```
ansible/
├── roles/              # Reusable Ansible roles
│   ├── common/         # Common utilities
│   ├── security/       # Security roles
│   └── monitoring/     # Monitoring roles
├── modules/            # Custom Ansible modules
├── plugins/            # Ansible plugins
│   ├── filter/         # Filter plugins
│   ├── callback/       # Callback plugins
│   └── lookup/         # Lookup plugins
├── library/            # Module library
└── ansible.cfg         # Default Ansible configuration
```

## Shared Roles

### common
Basic system setup and utilities used by all environments.

### security
Security hardening, compliance checking, and audit logging.

### monitoring
System monitoring, metrics collection, and alerting.

### app-*
Individual app installation roles referenced by the app store catalog.

## Using Shared Roles

In your playbook:

```yaml
---
- name: Example Playbook
  hosts: all
  roles:
    - role: shared/ansible/roles/common
    - role: shared/ansible/roles/security
```

## Custom Modules

Custom Ansible modules for framework-specific operations:

- `app_store`: Manage app store installations
- `foss_package`: Manage FOSS package repository
- `layer_config`: Handle configuration layer inheritance

## Configuration Inheritance

The framework uses a configuration inheritance system where each layer can override the previous:

```
Base Variables
    ↓ (inherited by)
Organization Variables
    ↓ (inherited by)
Program Variables
```

Variables are merged with later layers taking precedence.
