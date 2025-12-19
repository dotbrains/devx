# Quick Start

Get up and running with the Developer Environment Framework in under 10 minutes.

## 5-Minute Setup

### Step 1: Clone and Navigate

```bash
git clone https://github.com/dotbrains/devx.git
cd devx
```

### Step 2: Use Example Program

```bash
cd packages/programs/example-project
vagrant up
```

That's it! You now have a fully configured development environment.

### Step 3: Access Your Environment

```bash
vagrant ssh
```

You'll be in a Rocky Linux environment with:

- Docker
- Kubernetes tools (kubectl, helm, k9s)
- Python 3 with common packages
- Node.js with npm
- Git and other dev tools

**Note:** The framework supports both Rocky Linux 8 and 9 base images.

## What Just Happened?

The framework:

1. ✅ Created a VM from the base Rocky Linux image
2. ✅ Applied security hardening (SELinux, firewall, SSH)
3. ✅ Installed organization-approved tools
4. ✅ Set up the FOSS package ecosystem
5. ✅ Applied program-specific configurations

## Next: Customize Your Environment

### Enable Additional Apps

Edit `ansible/group_vars/all.yml`:

```yaml
apps:
  docker:
    enabled: true
  k9s:
    enabled: true
  helm:
    enabled: true
  vscode:
    enabled: true  # Add VS Code
```

Apply changes:

```bash
vagrant provision
```

### Install FOSS Packages

Inside the VM:

```bash
# Install the CLI
/vagrant/../../organization/foss-packages/scripts/install-foss-cli.sh

# Search packages
foss-cli search flask

# View package info
foss-cli info flask
```

## Common Operations

### Start/Stop Environment

```bash
vagrant up      # Start
vagrant halt    # Stop
vagrant reload  # Restart
```

### Update Configuration

```bash
# Edit configs
vim ansible/group_vars/all.yml

# Apply changes
vagrant provision
```

### Clean Up

```bash
vagrant destroy  # Delete VM
```

## What's Next?

- [Full Getting Started Guide](getting-started.md) - Detailed setup instructions
- [Common Tasks](common-tasks.md) - Frequently performed operations
- [Configuration Guide](configuration.md) - Customize your environment
- [App Store](app-store.md) - Explore available tools
