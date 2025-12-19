# Configuration Guide

Comprehensive guide to configuring the Developer Environment Framework.

## Overview

The framework uses a layered configuration system where each tier can override or extend previous configurations.

## Configuration Files

### Base Layer
- `packages/base/ansible/group_vars/all.yml` - Base system configuration

### Organization Layer
- `packages/organization/ansible/group_vars/all.yml` - Organization settings
- `packages/organization/ansible/group_vars/apps.yml` - App store configuration

### Program Layer
- `packages/programs/*/ansible/group_vars/all.yml` - Program-specific settings

## Variable Precedence

Variables are resolved in this order: **Base → Organization → Program**

Higher tiers override lower tiers.

## Common Configuration Tasks

See [Common Tasks](common-tasks.md) for practical examples.

## Advanced Configuration

Detailed configuration options for fine-tuning each component of the framework.

### System Configuration

Base system settings in `packages/base/ansible/group_vars/all.yml`:

```yaml
# System Configuration
base_os_version: "9"
base_hostname_prefix: "devenv"
base_timezone: "UTC"
```

**Available Options:**

- `base_os_version` - Operating system major version (8 or 9)
- `base_hostname_prefix` - Prefix for hostname generation
- `base_timezone` - System timezone (e.g., "UTC", "America/New_York")

### Security Configuration

Security hardening and access control:

```yaml
# Security Settings
base_security_hardening: true
base_selinux_state: enforcing
base_firewall_enabled: true
base_ssh_password_auth: false
base_ssh_root_login: false
```

**Available Options:**

- `base_security_hardening` - Enable system hardening (CIS benchmarks)
- `base_selinux_state` - SELinux mode: `enforcing`, `permissive`, or `disabled`
- `base_firewall_enabled` - Enable firewalld
- `base_ssh_password_auth` - Allow SSH password authentication
- `base_ssh_root_login` - Allow root login via SSH

**Program-Level Firewall:**
```yaml
# Open specific ports for your application
program_firewall_ports:
  - 3000  # Application server
  - 5432  # PostgreSQL
  - 6379  # Redis
```

### Airgapped Configuration

For disconnected or restricted environments:

```yaml
# Airgapped Configuration
base_airgapped_mode: false
base_local_repo_url: ""
```

**Available Options:**

- `base_airgapped_mode` - Enable airgapped operation (no internet access)
- `base_local_repo_url` - Local repository mirror URL

**Example with local mirror:**
```yaml
base_airgapped_mode: true
base_local_repo_url: "http://repo.internal.company.com/rocky9"
```

### Package Management

Control system package installation:

```yaml
# Package Management
base_minimal_install: true
base_essential_packages:
  - vim
  - git
  - curl
  - wget
  - tar
  - gzip
  - sudo
  - tmux
```

**Available Options:**

- `base_minimal_install` - Install only essential packages
- `base_essential_packages` - List of core packages to install

**Add custom packages:**
```yaml
program_additional_packages:
  - htop
  - ncdu
  - jq
  - tree
```

### Network Configuration

Network settings and DNS:

```yaml
# Network Configuration
base_network_mode: "dhcp"
base_dns_servers:
  - 8.8.8.8
  - 8.8.4.4
```

**Available Options:**

- `base_network_mode` - Network configuration mode: `dhcp` or `static`
- `base_dns_servers` - DNS resolver addresses

**Static IP configuration:**
```yaml
base_network_mode: "static"
base_static_ip: "192.168.1.100"
base_static_netmask: "255.255.255.0"
base_static_gateway: "192.168.1.1"
```

### Vagrant VM Configuration

VM resource allocation in `Vagrantfile`:

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.name = "my-project-dev"
  vb.memory = "8192"      # RAM in MB
  vb.cpus = 4             # CPU cores
  vb.gui = false          # Headless mode
end
```

**Network Options:**
```ruby
# Private network with static IP
config.vm.network "private_network", ip: "192.168.56.10"

# Port forwarding
config.vm.network "forwarded_port", guest: 8080, host: 8080

# Bridged network (direct network access)
config.vm.network "public_network", bridge: "en0: Wi-Fi"
```

**Synced Folders:**
```ruby
# Default project sync
config.vm.synced_folder ".", "/vagrant"

# Custom paths
config.vm.synced_folder "./data", "/data", 
  type: "rsync",
  rsync__exclude: [".git/", "node_modules/"]

# NFS for better performance
config.vm.synced_folder "./code", "/code", type: "nfs"
```

### User Management

User and group configuration:

```yaml
# User Management
base_admin_group: "wheel"
base_default_shell: "/bin/bash"
```

**Create additional users:**
```yaml
program_users:
  - name: "appuser"
    groups: ["docker", "wheel"]
    shell: "/bin/bash"
    create_home: true
  - name: "deployuser"
    groups: ["docker"]
    shell: "/bin/bash"
    ssh_key: "{{ lookup('file', '~/.ssh/deploy_key.pub') }}"
```

### Monitoring and Logging

System monitoring configuration:

```yaml
# Monitoring
base_monitoring_enabled: true
base_logging_level: "info"
```

**Available Options:**

- `base_monitoring_enabled` - Enable system monitoring
- `base_logging_level` - Log level: `debug`, `info`, `warn`, `error`

**Program-specific monitoring:**
```yaml
program_monitoring_enabled: true
program_monitoring_endpoints:
  - name: "app-health"
    url: "http://localhost:3000/health"
    interval: 60
  - name: "database"
    url: "postgresql://localhost:5432"
    interval: 300
```

### Performance Tuning

System performance optimization:

```yaml
# Performance Tuning
base_swap_size_mb: 2048
base_kernel_params: {}
```

**Advanced kernel parameters:**
```yaml
base_kernel_params:
  vm.swappiness: 10
  fs.file-max: 2097152
  net.core.somaxconn: 1024
  net.ipv4.tcp_max_syn_backlog: 2048
```

**Application-specific tuning:**
```yaml
# Node.js
program_nodejs_max_memory: "2048"
program_nodejs_gc_interval: "1000"

# PostgreSQL
program_postgres_shared_buffers: "256MB"
program_postgres_max_connections: "100"

# Redis
program_redis_maxmemory: "256mb"
program_redis_maxmemory_policy: "allkeys-lru"
```

### Environment Variables

Set environment variables for applications:

```yaml
# Environment variables
program_env_vars:
  NODE_ENV: "{{ program_environment }}"
  DATABASE_URL: "postgresql://user:pass@localhost:5432/mydb"
  REDIS_URL: "redis://localhost:6379"
  LOG_LEVEL: "debug"
  API_KEY: "{{ vault_api_key }}"
```

### CI/CD Integration

Continuous integration configuration:

```yaml
# CI/CD Integration
program_ci_integration: "github-actions"
program_ci_config:
  webhook_url: "https://api.github.com/repos/user/repo/dispatches"
  build_on_provision: false
  deploy_on_success: true
```

### Repository Management

Automatic repository cloning and setup:

```yaml
# Program repository
program_repo_url: "https://github.com/example/project.git"
program_repo_branch: "main"
program_clone_on_provision: true
program_repo_destination: "/opt/{{ program_name }}"
```

### FOSS Package Configuration

FOSS package system settings:

```yaml
# FOSS Package Repository
org_foss_enabled: true
org_foss_repository_url: ""  # Leave empty for default
org_foss_security_scanning: true
org_foss_auto_updates: false
```

**Available Options:**

- `org_foss_enabled` - Enable FOSS package system
- `org_foss_repository_url` - Internal mirror URL (optional)
- `org_foss_security_scanning` - Enable security vulnerability scanning
- `org_foss_auto_updates` - Automatically update packages

### Ansible Provisioning Options

Control Ansible behavior in `Vagrantfile`:

```ruby
config.vm.provision "ansible" do |ansible|
  ansible.playbook = "ansible/playbooks/program-setup.yml"
  ansible.config_file = "ansible/ansible.cfg"
  ansible.verbose = true              # Show detailed output
  ansible.limit = "all"               # Target hosts
  ansible.tags = ["setup", "config"]  # Run specific tags
  ansible.skip_tags = ["slow"]        # Skip tags
  ansible.extra_vars = {
    program_layer: true,
    environment: "development"
  }
end
```

### Development Tools

Development-specific features:

```yaml
# Development tools
program_dev_tools:
  hot_reload: true
  debug_mode: true
  source_maps: true
  profiling_enabled: false
```

### Build Cleanup

Automatic cleanup after provisioning:

```yaml
# Cleanup
base_cleanup_after_build: true
```

**Available Options:**

- `base_cleanup_after_build` - Remove temporary files and caches after build

### Configuration Validation

Before applying changes, validate your configuration:

```bash
# Check Ansible syntax
make validate

# Lint configuration files
make lint

# Dry-run provisioning
vagrant provision --dry-run
```

### Configuration Templates

Use templates for complex configurations:

```yaml
# Reference template variables
program_config_template: "templates/app-config.j2"
program_config_destination: "/opt/{{ program_name }}/config.yml"
```

### Multi-Environment Configuration

Manage different environments:

```yaml
program_environment: "{{ environment | default('development') }}"

# Environment-specific overrides
program_env_configs:
  development:
    debug: true
    log_level: "debug"
  staging:
    debug: false
    log_level: "info"
  production:
    debug: false
    log_level: "error"
```

**Deploy with environment:**
```bash
ENV=staging vagrant up
ENV=production vagrant provision
```
