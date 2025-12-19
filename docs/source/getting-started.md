# Getting Started

This guide will help you set up and start using the Developer Environment Framework.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required

- **Vagrant** (>= 2.3.0): [Download](https://www.vagrantup.com/downloads)
- **VirtualBox** (>= 6.1) or another Vagrant provider: [Download](https://www.virtualbox.org/)
- **Ansible** (>= 2.14): `pip install ansible` or [Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

### Optional

- **Git**: For version control
- **Python 3.8+**: For running scripts and tools
- **Make**: For using Makefile commands (usually pre-installed on Unix systems)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/dotbrains/devx.git
cd devx
```

### 2. Verify Prerequisites

```bash
# Check Vagrant
vagrant --version

# Check VirtualBox
VBoxManage --version

# Check Ansible
ansible --version
```

### 3. Review Configuration

Browse the default configurations:

```bash
# Base layer configuration
cat packages/base/ansible/group_vars/all.yml

# Organization apps
cat packages/organization/ansible/group_vars/apps.yml
```

## Building Your First Environment

### Option 1: Build Base Layer

The base layer provides a hardened Rocky 9 image:

```bash
# Build the base image
make build-base

# This will:
# 1. Create a VM from Rocky 9
# 2. Apply security hardening
# 3. Package it as a Vagrant box
```

**Time**: ~15-20 minutes

**Output**: `packages/base/artifacts/base-rocky9.box`

### Option 2: Build Organization Spin

Build a complete organization environment with developer tools:

```bash
# Ensure base image is built first
make build-base

# Build organization spin
make build-org-standard

# This will:
# 1. Use the base box
# 2. Install app store tools
# 3. Set up FOSS package system
```

**Time**: ~10-15 minutes

**Output**: Running VM with all tools installed

### Option 3: Quick Start with Example Program

Use the example program for a complete setup:

```bash
# Navigate to example program
cd packages/programs/example-project

# Start the environment
vagrant up

# SSH into the environment
vagrant ssh
```

## Verifying Installation

### Run Tests

```bash
# Run all tests
make test

# Test specific layers
make test-base
make test-org
```

### Check Installed Tools

SSH into your environment and verify:

```bash
# SSH into the VM
vagrant ssh

# Check installed tools
docker --version
kubectl version --client
python3 --version
node --version
```

## Next Steps

### Explore the App Store

View available applications:

```bash
cat packages/organization/app-store/catalog.yml
```

Enable/disable apps by editing:

```bash
vim packages/organization/ansible/group_vars/apps.yml
```

### Use FOSS Packages

Install the CLI tool:

```bash
cd packages/organization/foss-packages
./scripts/install-foss-cli.sh
```

Search for packages:

```bash
foss-cli search python
foss-cli info requests
```

### Create Your First Program

```bash
# Create a new program
make init-program
# Enter name: my-project

# Navigate to the new program
cd packages/programs/my-project

# Customize configuration
vim ansible/group_vars/all.yml

# Start the environment
vagrant up
```

## Configuration Basics

### Understanding Variable Precedence

Variables are resolved in this order:

1. **Base** (`packages/base/ansible/group_vars/all.yml`)
2. **Organization** (`packages/organization/ansible/group_vars/apps.yml`)
3. **Program** (`packages/programs/*/ansible/group_vars/all.yml`)

Higher tiers override lower tiers.

### Example: Enabling Docker

=== "Organization Level"

    ```yaml
    # packages/organization/ansible/group_vars/apps.yml
    apps:
      docker:
        enabled: true
        version: "24.0"
    ```

=== "Program Level"

    ```yaml
    # packages/programs/my-project/ansible/group_vars/all.yml
    apps:
      docker:
        enabled: true
        version: "23.0.6"  # Override to specific version
    ```

### Example: Adding Python Packages

```yaml
# packages/programs/my-project/ansible/group_vars/all.yml
apps:
  python:
    enabled: true
    packages:
      - requests
      - flask
      - pytest
```

## Common Commands

### Makefile Commands

```bash
# Building
make build-base           # Build base image
make build-org-standard   # Build organization spin
make build-all            # Build all layers

# Testing
make test                 # Run all tests
make test-base            # Test base layer
make test-org             # Test organization layer

# Documentation
make docs                 # Build documentation
make serve-docs           # Serve docs locally

# Cleanup
make clean                # Clean Vagrant environments
make clean-artifacts      # Remove built artifacts
```

### Vagrant Commands

```bash
# Start/stop environments
vagrant up                # Start VM
vagrant halt              # Stop VM
vagrant reload            # Restart VM
vagrant destroy           # Delete VM

# Provisioning
vagrant provision         # Re-run Ansible
vagrant up --provision    # Start and provision

# Access
vagrant ssh               # SSH into VM
vagrant ssh-config        # Show SSH config
```

## Troubleshooting

### VM Won't Start

```bash
# Check VirtualBox is running
VBoxManage list vms

# Try with verbose output
vagrant up --debug

# Destroy and recreate
vagrant destroy -f
vagrant up
```

### Provisioning Fails

```bash
# Re-run provisioning
vagrant provision

# Check Ansible syntax
ansible-playbook --syntax-check packages/base/ansible/playbooks/base-setup.yml
```

### Network Issues

```bash
# Check network configuration
vagrant ssh -c "ip addr show"

# Restart networking
vagrant ssh -c "sudo systemctl restart NetworkManager"
```

For more troubleshooting, see the [Troubleshooting Guide](troubleshooting.md).

## Learning Resources

- [Architecture Overview](architecture.md): Understand the framework design
- [App Store Guide](app-store.md): Learn about available applications
- [Creating Programs](creating-programs.md): Build custom environments
- [API Reference](api-reference.md): Use the REST API and CLI

## Getting Help

- Check the [FAQ](faq.md)
- Browse [Common Tasks](common-tasks.md)
- Read the [Troubleshooting Guide](troubleshooting.md)
- Open an issue on GitHub
