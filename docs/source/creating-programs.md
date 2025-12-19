# Creating Programs

Learn how to create custom program environments for your projects.

## Overview

Program environments are project-specific configurations that inherit from the organization layer while adding custom tooling and settings.

## Quick Start

### Using the Makefile

```bash
make init-program
# Enter program name: my-project
```

This creates a new program at `packages/programs/my-project/`.

### Manual Creation

```bash
cp -r packages/programs/templates/basic packages/programs/my-project
cd packages/programs/my-project
```

## Program Structure

```
packages/programs/my-project/
├── Vagrantfile              # VM configuration
├── ansible/
│   ├── group_vars/
│   │   └── all.yml         # Program variables
│   ├── playbooks/
│   │   └── program-setup.yml  # Main playbook
│   └── roles/              # Custom roles (optional)
└── README.md               # Program documentation
```

## Configuration

### Basic Configuration

Edit `ansible/group_vars/all.yml`:

```yaml
---
# Program Information
program_name: "my-project"
program_description: "My awesome project"

# App Configuration (inherits from organization)
apps:
  docker:
    enabled: true
    version: "24.0"
  
  python:
    enabled: true
    version: "3.11"
    packages:
      - flask
      - requests
      - pytest
  
  nodejs:
    enabled: true
    version: "18"
    packages:
      - typescript
      - eslint

# Program-specific settings
project_path: "/opt/my-project"
custom_env_vars:
  APP_ENV: "development"
  LOG_LEVEL: "debug"
```

### Override Organization Settings

```yaml
# Override Docker version from organization default
apps:
  docker:
    enabled: true
    version: "23.0.6"  # Specific version needed
    
# Disable tools you don't need
apps:
  k9s:
    enabled: false
```

### Add Custom Variables

```yaml
# Database configuration
database:
  host: "localhost"
  port: 5432
  name: "myapp_dev"

# API settings  
api:
  base_url: "http://localhost:8000"
  timeout: 30
```

## Vagrantfile Customization

### Resource Allocation

```ruby
Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "8192"  # 8GB RAM
    vb.cpus = 4         # 4 CPU cores
  end
end
```

### Port Forwarding

```ruby
config.vm.network "forwarded_port", guest: 8000, host: 8000  # API
config.vm.network "forwarded_port", guest: 3000, host: 3000  # Frontend
config.vm.network "forwarded_port", guest: 5432, host: 5432  # Database
```

### Shared Folders

```ruby
config.vm.synced_folder "./src", "/opt/my-project/src"
config.vm.synced_folder "./data", "/data"
```

### Private Network

```ruby
config.vm.network "private_network", ip: "192.168.33.10"
```

## Custom Playbooks

### Project Setup Playbook

Edit `ansible/playbooks/program-setup.yml`:

```yaml
---

- name: Setup My Project
  hosts: all
  become: true
  
  tasks:
    - name: Create project directory
      ansible.builtin.file:
        path: "{{ project_path }}"
        state: directory
        owner: vagrant
        group: vagrant
    
    - name: Clone repository
      ansible.builtin.git:
        repo: "https://github.com/org/my-project.git"
        dest: "{{ project_path }}"
        version: main
      become_user: vagrant
    
    - name: Install project dependencies
      ansible.builtin.command:
        cmd: pip install -r requirements.txt
        chdir: "{{ project_path }}"
      become_user: vagrant
    
    - name: Setup database
      ansible.builtin.command:
        cmd: python manage.py migrate
        chdir: "{{ project_path }}"
      become_user: vagrant
```

### Using Custom Roles

Create custom roles in `ansible/roles/`:

```bash
mkdir -p ansible/roles/myapp
cd ansible/roles/myapp
mkdir -p tasks defaults templates
```

`ansible/roles/myapp/tasks/main.yml`:
```yaml
---

- name: Install application
  ansible.builtin.template:
    src: config.j2
    dest: /etc/myapp/config.yml

- name: Start application service
  ansible.builtin.systemd:
    name: myapp
    state: started
    enabled: true
```

Include in playbook:
```yaml
- name: Setup My Project
  hosts: all
  become: true
  roles:
    - myapp
```

## Common Patterns

### Web Application

```yaml
apps:
  docker: { enabled: true }
  nodejs: { enabled: true, version: "18" }
  python: { enabled: true, version: "3.11" }
  postgres: { enabled: true, version: "15" }
  redis: { enabled: true }

services:
  - name: api
    port: 8000
  - name: frontend
    port: 3000
```

### Data Science

```yaml
apps:
  python:
    enabled: true
    version: "3.11"
    packages:
      - numpy
      - pandas
      - scikit-learn
      - jupyter
      - matplotlib
  
jupyter:
  enabled: true
  port: 8888
  token: "{{ vault_jupyter_token }}"
```

### Microservices

```yaml
apps:
  docker: { enabled: true }
  kubernetes: { enabled: true }
  helm: { enabled: true }
  k9s: { enabled: true }

services:
  - { name: "auth", port: 8001 }
  - { name: "api", port: 8002 }
  - { name: "worker", port: 8003 }
```

## Building and Running

### First Time Setup

```bash
cd packages/programs/my-project
vagrant up
```

### Access Environment

```bash
vagrant ssh
```

### Apply Configuration Changes

```bash
vagrant provision
```

### Rebuild Environment

```bash
vagrant destroy -f
vagrant up
```

## Testing Your Program

Create program-specific tests:

```bash
mkdir -p tests
cat > tests/test-program.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "Testing program setup..."

# Test project directory exists
if [ ! -d "/opt/my-project" ]; then
    echo "ERROR: Project directory not found"
    exit 1
fi

# Test application is running
if ! curl -s http://localhost:8000/health > /dev/null; then
    echo "ERROR: Application not responding"
    exit 1
fi

echo "Program tests passed"
EOF

chmod +x tests/test-program.sh
```

## Documentation

Document your program in `README.md`:

```markdown
# My Project Environment

## Overview
Development environment for My Project.

## Prerequisites
- Base image built
- Organization spin configured

## Setup
\`\`\`bash
vagrant up
\`\`\`

## Access
- Application: http://localhost:8000
- Database: localhost:5432

## Development
\`\`\`bash
vagrant ssh
cd /opt/my-project
python manage.py runserver
\`\`\`

## Testing
\`\`\`bash
pytest
\`\`\`
```

## Best Practices

1. **Keep it Minimal**: Only override what you need
2. **Document Changes**: Explain why you override organization defaults
3. **Version Control**: Check in your program configuration
4. **Test Regularly**: Ensure your environment builds successfully
5. **Use Secrets Safely**: Never commit sensitive data
6. **Share Patterns**: Document successful patterns for team reuse

## Advanced Topics

- [Program Configuration](dev/program-config.md) - Advanced configuration
- [Custom Spins](dev/custom-spins.md) - Creating organization variants
- [Ansible Roles](dev/ansible-roles.md) - Developing custom roles
