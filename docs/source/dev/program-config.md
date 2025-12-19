# Program Configuration

Advanced configuration guide for program-level environments.

## Overview

Program configuration provides the most specific layer of customization, overriding both base and organization settings.

## Variable Precedence

Variables are resolved in order:

```
Base Layer (lowest priority)
  ↓
Organization Layer
  ↓
Program Layer (highest priority)
```

## Configuration Files

### Main Configuration

`packages/programs/my-project/ansible/group_vars/all.yml`:

```yaml
---
# Program identity
program_name: "my-project"
program_version: "1.0.0"
program_description: "My awesome project"

# Override organization settings
apps:
  docker:
    enabled: true
    version: "23.0.6"  # Specific version
    
  python:
    enabled: true
    version: "3.11"
    packages:
      - flask==2.3.0
      - requests==2.31.0
      - pytest==7.4.0

# Program-specific variables
project:
  name: "myapp"
  environment: "development"
  debug: true
  
database:
  host: "localhost"
  port: 5432
  name: "myapp_dev"
  
api:
  base_url: "http://localhost:8000"
  timeout: 30
```

## Advanced Patterns

### Environment-Specific Configuration

Use separate files for environments:

```yaml
# group_vars/all.yml
project_environment: "{{ lookup('env', 'PROJECT_ENV') | default('development') }}"

# group_vars/development.yml
api:
  debug: true
  log_level: "DEBUG"
  
# group_vars/production.yml
api:
  debug: false
  log_level: "INFO"
```

Load dynamically:

```yaml
- name: Load environment config
  ansible.builtin.include_vars:
    file: "{{ project_environment }}.yml"
```

### Secrets Management

Use Ansible Vault for sensitive data:

```bash
# Create vault file
ansible-vault create group_vars/vault.yml
```

`group_vars/vault.yml`:
```yaml
---
vault_db_password: "supersecret"
vault_api_key: "secret_key_here"
vault_jwt_secret: "jwt_secret"
```

Reference in configuration:
```yaml
database:
  password: "{{ vault_db_password }}"
  
api:
  key: "{{ vault_api_key }}"
```

### Dynamic Configuration

Use Jinja2 templating:

```yaml
# Conditional based on environment
api_url: |
  {% if project_environment == 'production' %}
  https://api.production.com
  {% else %}
  http://localhost:8000
  {% endif %}

# Computed values
worker_count: "{{ ansible_processor_vcpus }}"
memory_limit: "{{ (ansible_memtotal_mb * 0.8) | int }}m"
```

### Feature Flags

```yaml
features:
  new_api: true
  beta_features: false
  experimental:
    - feature_x
    - feature_y
```

Use in playbooks:
```yaml
- name: Enable new API
  ansible.builtin.template:
    src: new_api.conf.j2
    dest: /etc/app/api.conf
  when: features.new_api | default(false)
```

## Complex Examples

### Multi-Service Application

```yaml
services:
  api:
    port: 8000
    workers: 4
    timeout: 30
    
  frontend:
    port: 3000
    build_path: "./dist"
    
  worker:
    queue: "redis://localhost:6379"
    concurrency: 2
    
  database:
    type: "postgresql"
    host: "localhost"
    port: 5432
    name: "myapp"
```

### Microservices Configuration

```yaml
microservices:
  auth:
    port: 8001
    replicas: 2
    resources:
      memory: "512Mi"
      cpu: "500m"
      
  api:
    port: 8002
    replicas: 3
    resources:
      memory: "1Gi"
      cpu: "1000m"
      
  worker:
    replicas: 2
    queue: "rabbitmq"
```

### Development Tools Configuration

```yaml
dev_tools:
  vscode:
    extensions:
      - ms-python.python
      - dbaeumer.vscode-eslint
      - esbenp.prettier-vscode
    settings:
      "python.linting.enabled": true
      "editor.formatOnSave": true
      
  git:
    hooks:
      pre-commit:
        - black
        - flake8
        - pytest
```

## Testing Configuration

Create test configurations:

```yaml
# group_vars/test.yml
testing:
  database:
    name: "myapp_test"
    fixtures: true
    
  api:
    mock_external: true
    
  coverage:
    threshold: 80
```

## Configuration Validation

Validate configuration in playbooks:

```yaml
- name: Validate required variables
  ansible.builtin.assert:
    that:
      - program_name is defined
      - database.name is defined
      - api.base_url is defined
    fail_msg: "Required configuration missing"

- name: Validate port ranges
  ansible.builtin.assert:
    that:
      - api.port | int >= 1024
      - api.port | int <= 65535
    fail_msg: "Invalid port number"
```

## Best Practices

### 1. Document Configuration

Add comments explaining complex settings:

```yaml
# Database connection pool size
# Adjust based on expected concurrent connections
# Development: 5-10, Production: 20-50
pool_size: 10
```

### 2. Use Defaults

Provide sensible defaults:

```yaml
log_level: "{{ lookup('env', 'LOG_LEVEL') | default('INFO') }}"
```

### 3. Separate Concerns

Organize by domain:

```
group_vars/
├── all.yml          # Main config
├── database.yml     # Database settings
├── api.yml          # API configuration
├── services.yml     # Service definitions
└── vault.yml        # Secrets
```

### 4. Version Control

Commit configuration (except secrets):

```bash
git add group_vars/all.yml
git commit -m "feat: add API configuration"
```

### 5. Environment Variables

Allow override via environment:

```yaml
api_key: "{{ lookup('env', 'API_KEY') | default(vault_api_key) }}"
```

## See Also

- [Creating Programs](../creating-programs.md)
- [Configuration Guide](../configuration.md)
- [Ansible Roles](ansible-roles.md)
