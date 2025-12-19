# Custom Spins

Guide for creating custom organization-specific variants of the developer environment.

## Overview

Custom spins are organization-level variants that:

- Extend the base image
- Add organization-specific tools
- Apply custom configurations
- Serve as starting points for programs

## Creating a Custom Spin

### 1. Directory Structure

Create a new spin:

```bash
mkdir -p packages/organization/spins/my-spin
cd packages/organization/spins/my-spin
```

Structure:
```
my-spin/
├── Vagrantfile              # VM configuration
├── ansible/
│   ├── group_vars/
│   │   └── all.yml         # Spin-specific variables
│   ├── playbooks/
│   │   └── spin-setup.yml  # Setup playbook
│   └── roles/              # Custom roles (optional)
└── README.md               # Documentation
```

### 2. Vagrantfile

Create `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|
  # Use base image
  config.vm.box = "base-rocky9"
  
  # VM settings
  config.vm.hostname = "my-spin"
  
  # Resources
  config.vm.provider "virtualbox" do |vb|
    vb.name = "my-spin"
    vb.memory = "4096"
    vb.cpus = 2
  end
  
  # Ansible provisioning
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/playbooks/spin-setup.yml"
    ansible.groups = {
      "spin" => ["default"]
    }
  end
end
```

### 3. Configuration

`ansible/group_vars/all.yml`:

```yaml
---
# Spin Information
spin_name: "my-spin"
spin_description: "Custom spin for specific use case"

# Inherit from organization apps
apps:
  docker:
    enabled: true
    version: "24.0"
  
  python:
    enabled: true
    version: "3.11"
    packages:
      - requests
      - flask
  
  nodejs:
    enabled: true
    version: "18"

# Spin-specific configuration
custom_tools:
  - name: "internal-cli"
    version: "1.0.0"
    repository: "https://github.com/org/internal-cli"

# Organization settings
organization:
  name: "MyOrg"
  domain: "example.com"
  proxy: "http://proxy.example.com:8080"
```

### 4. Setup Playbook

`ansible/playbooks/spin-setup.yml`:

```yaml
---

- name: Setup Custom Spin
  hosts: all
  become: true
  
  pre_tasks:
    - name: Display spin information
      ansible.builtin.debug:
        msg: "Setting up {{ spin_name }}"
  
  roles:
    # Include organization roles
    - role: app-docker
      when: apps.docker.enabled | default(false)
    
    - role: app-python
      when: apps.python.enabled | default(false)
    
    - role: app-nodejs
      when: apps.nodejs.enabled | default(false)
  
  tasks:
    - name: Install custom tools
      ansible.builtin.git:
        repo: "{{ item.repository }}"
        dest: "/opt/{{ item.name }}"
        version: "{{ item.version }}"
      loop: "{{ custom_tools }}"
    
    - name: Configure organization proxy
      ansible.builtin.template:
        src: proxy.conf.j2
        dest: /etc/profile.d/proxy.sh
      when: organization.proxy is defined
    
    - name: Create spin marker
      ansible.builtin.copy:
        content: |
          Spin: {{ spin_name }}
          Version: {{ spin_version | default('1.0.0') }}
          Built: {{ ansible_date_time.iso8601 }}
        dest: /etc/spin-info
```

### 5. Building the Spin

```bash
# Build
cd packages/organization/spins/my-spin
vagrant up

# Package (optional)
vagrant package --output ../../artifacts/my-spin.box

# Add to Vagrant
vagrant box add my-spin ../../artifacts/my-spin.box
```

## Use Cases

### Development Spin

Pre-configured for web development:

```yaml
apps:
  docker: { enabled: true }
  python: { enabled: true, version: "3.11" }
  nodejs: { enabled: true, version: "18" }
  postgresql: { enabled: true, version: "15" }
  redis: { enabled: true }
```

### Data Science Spin

Optimized for data science work:

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
  
  r:
    enabled: true
    version: "4.3"
    packages:
      - tidyverse
      - ggplot2
```

### DevOps Spin

Tooling for infrastructure work:

```yaml
apps:
  docker: { enabled: true }
  kubernetes: { enabled: true }
  terraform: { enabled: true }
  ansible: { enabled: true }
  helm: { enabled: true }
  k9s: { enabled: true }
```

## Best Practices

### Naming Conventions

- Use descriptive names: `data-science-spin`, `devops-spin`
- Follow semantic versioning
- Document purpose clearly

### Configuration Management

- Keep spin-specific settings minimal
- Document deviations from standard organization setup
- Use variables for flexibility

### Testing

Create tests for your spin:

```bash
mkdir -p tests
cat > tests/verify-spin.yml << 'EOF'
---

- name: Verify Custom Spin
  hosts: all
  tasks:
    - name: Check spin marker
      ansible.builtin.stat:
        path: /etc/spin-info
      register: spin_marker
    
    - name: Verify tools installed
      ansible.builtin.command:
        cmd: "{{ item }} --version"
      loop:
        - docker
        - python3
        - node
EOF
```

### Documentation

Create comprehensive README:

```markdown
# My Custom Spin

## Purpose
Optimized for [specific use case]

## Installed Tools
- Docker 24.0
- Python 3.11
- Node.js 18
- [Custom tool list]

## Configuration
- Organization proxy configured
- Custom repositories added
- Specific settings applied

## Usage
\`\`\`bash
vagrant init my-spin
vagrant up
\`\`\`

## Differences from Standard Spin
- [List key differences]
```

## Maintenance

### Updating Spins

1. Update configuration/playbooks
2. Test changes thoroughly
3. Rebuild and repackage
4. Update version number
5. Distribute to teams

### Version Control

Commit spin configurations:

```bash
git add packages/organization/spins/my-spin/
git commit -m "feat: add my-spin v1.1.0"
git tag -a my-spin-v1.1.0 -m "My Spin version 1.1.0"
```

### Distribution

Share spins with organization:

```bash
# Upload to artifact repository
cp artifacts/my-spin.box /shared/vagrant-boxes/

# Or use Vagrant Cloud
vagrant cloud publish org/my-spin 1.1.0 virtualbox artifacts/my-spin.box
```

## Troubleshooting

### Spin Won't Build

- Verify base image exists: `vagrant box list | grep base-rocky9`
- Check Ansible syntax: `ansible-playbook --syntax-check playbooks/spin-setup.yml`
- Review logs: `vagrant up --debug`

### Configuration Not Applied

- Check variable precedence
- Verify playbook execution
- Test with `vagrant provision`

## See Also

- [Architecture](../architecture.md)
- [Creating Programs](../creating-programs.md)
- [Ansible Roles](ansible-roles.md)
