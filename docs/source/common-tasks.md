# Common Tasks

Frequently performed operations with the Developer Environment Framework.

## Environment Management

### Create a New Program Environment

```bash
# Use the Makefile helper
make init-program

# Or manually copy the template
cp -r packages/programs/templates/basic packages/programs/my-project
cd packages/programs/my-project
```

### Start an Environment

```bash
cd packages/programs/my-project
vagrant up
```

### Stop an Environment

```bash
vagrant halt          # Graceful shutdown
vagrant suspend       # Save state (faster restart)
```

### Restart an Environment

```bash
vagrant reload        # Hard restart
vagrant reload --provision  # Restart and re-provision
```

### Delete an Environment

```bash
vagrant destroy       # Prompts for confirmation
vagrant destroy -f    # Force delete without prompt
```

## Configuration Changes

### Add a New Tool

1. Edit `ansible/group_vars/all.yml`:

```yaml
apps:
  new_tool:
    enabled: true
    version: "1.2.3"
```

2. Apply changes:

```bash
vagrant provision
```

### Change Tool Version

1. Update version in `ansible/group_vars/all.yml`:

```yaml
apps:
  docker:
    version: "24.0"  # Change from 23.0
```

2. Re-provision:

```bash
vagrant provision
```

### Override Organization Settings

In your program's `ansible/group_vars/all.yml`:

```yaml
# Override Docker version from organization default
apps:
  docker:
    version: "23.0.6"

# Add program-specific Python packages
apps:
  python:
    packages:
      - requests
      - custom-internal-library
```

## Testing

### Run All Tests

```bash
make test
```

### Test Specific Layer

```bash
make test-base        # Base layer only
make test-org         # Organization layer only
```

### Validate Configuration

```bash
# Check Ansible syntax
make validate

# Lint playbooks
make lint
```

## FOSS Package Management

### Search for Packages

```bash
foss-cli search python
foss-cli search -e python  # Ecosystem filter
```

### View Package Details

```bash
foss-cli info requests
```

### Check Security Status

```bash
foss-cli security requests
```

### Submit a Package

```bash
foss-cli submit \
  --name my-package \
  --version 1.0.0 \
  --ecosystem pypi \
  --license MIT
```

### List All Packages

```bash
foss-cli list
foss-cli list --status approved
```

## Building Images

### Build Base Image

```bash
# Rocky Linux 9 (recommended)
make build-base
make build-base-rocky9

# Rocky Linux 8
make build-base-rocky8

# Build all base images
make build-all
```

Output:

- `packages/base/artifacts/base-rocky9.box`
- `packages/base/artifacts/base-rocky8.box`

### Build Organization Spin

```bash
make build-org-standard
```

### Build All Layers

```bash
make build-all
```

## Accessing Environments

### SSH Into VM

#### Standard Vagrant SSH

```bash
cd packages/programs/my-project
vagrant ssh
```

#### Using vagrant-ssh Wrapper (Recommended)

The `vagrant-ssh` script provides enhanced functionality with auto-discovery:

```bash
# SSH to any VM by name from anywhere
./scripts/vagrant-ssh base-rocky9
./scripts/vagrant-ssh standard-devenv
```

### Run Single Command

#### Standard Method

```bash
vagrant ssh -c "docker ps"
vagrant ssh -c "python3 --version"
```

#### Using vagrant-ssh Wrapper

```bash
# Execute commands from anywhere
./scripts/vagrant-ssh standard-devenv "docker ps"
./scripts/vagrant-ssh base-rocky9 "systemctl status"

# Execute in specific directory
./scripts/vagrant-ssh standard-devenv --workdir /workspace "git status"
./scripts/vagrant-ssh standard-devenv --workdir /vagrant "make test"
```

### Start Shell in Specific Directory

```bash
# Start interactive shell in /workspace
./scripts/vagrant-ssh standard-devenv --workdir /workspace
```

### Get SSH Config

```bash
vagrant ssh-config
```

Use with direct SSH:

```bash
vagrant ssh-config > ssh-config
ssh -F ssh-config default
```

## File Sharing

### Default Shared Folder

The project directory is mounted at `/vagrant`:

```bash
vagrant ssh
ls /vagrant  # Your project files
```

### Add Custom Shared Folders

Edit `Vagrantfile`:

```ruby
config.vm.synced_folder "./data", "/data"
```

## Networking

### Access Services from Host

Forward ports in `Vagrantfile`:

```ruby
config.vm.network "forwarded_port", guest: 8000, host: 8000
```

Apply changes:

```bash
vagrant reload
```

### Check VM IP

```bash
vagrant ssh -c "ip addr show"
```

## Troubleshooting

### Re-provision Failed Setup

```bash
vagrant provision
```

### View Ansible Output

```bash
vagrant up --provision --debug
```

### Reset to Clean State

```bash
vagrant destroy -f
vagrant up
```

### Check VM Status

```bash
vagrant status          # Current project
vagrant global-status   # All VMs
```

### Clean Up Old VMs

```bash
vagrant global-status --prune
```

## Backup and Restore

### Export VM State

```bash
vagrant halt
vagrant package --output my-backup.box
```

### Restore from Backup

```bash
vagrant box add my-backup my-backup.box
```

Update Vagrantfile:

```ruby
config.vm.box = "my-backup"
```

## Documentation

### Build Docs Locally

```bash
make docs
```

Output: `docs/site/`

### Serve Docs Locally

```bash
make serve-docs
```

Browse to: http://localhost:8000

## Maintenance

### Clean Vagrant Files

```bash
make clean
```

### Remove Built Artifacts

```bash
make clean-artifacts
```

### Update Vagrant Boxes

```bash
vagrant box update
vagrant box prune  # Remove old versions
```

## Advanced Operations

### Use Different Provider

```bash
vagrant up --provider=vmware_desktop
vagrant up --provider=libvirt
```

### Set Resource Limits

Edit `Vagrantfile`:

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = "8192"
  vb.cpus = 4
end
```

### Create Snapshots

```bash
vagrant snapshot save my-snapshot
vagrant snapshot restore my-snapshot
vagrant snapshot list
```

### Run Ansible Separately

```bash
ansible-playbook \
  -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory \
  ansible/playbooks/program-setup.yml
```

## Getting Help

For more detailed information:

- [Troubleshooting Guide](troubleshooting.md)
- [Configuration Guide](configuration.md)
- [API Reference](api-reference.md)
