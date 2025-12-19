# Utility Scripts

The DevX framework includes utility scripts in the `scripts/` directory to streamline common workflows.

## vagrant-ssh

Smart wrapper for `vagrant ssh` that eliminates the need to navigate to specific Vagrant box directories.

### Key Features

- **Auto-discovery**: Finds the correct Vagrant box directory by name
- **Ctrl+C protection**: Prevents accidental SSH session termination
- **Working directory support**: Start sessions or run commands in specific directories
- **Command execution**: Run one-off commands without entering interactive mode

### Basic Usage

#### Interactive SSH

Connect to any VM by name from anywhere in your repository:

```bash
./scripts/vagrant-ssh base-rocky8
./scripts/vagrant-ssh base-rocky9
./scripts/vagrant-ssh standard-devenv
./scripts/vagrant-ssh example-project
```

No need to `cd` to the Vagrantfile directory first - the script finds it automatically.

#### Execute Commands

Run a single command and exit:

```bash
# Check Docker containers
./scripts/vagrant-ssh standard-devenv "docker ps"

# View system status
./scripts/vagrant-ssh base-rocky9 "systemctl status"

# Run tests
./scripts/vagrant-ssh example-project "pytest tests/"
```

### Working Directory Support

The `--workdir` flag changes to a directory before executing commands or starting an interactive shell.

#### Execute Command in Directory

```bash
# Run git status in /workspace
./scripts/vagrant-ssh standard-devenv --workdir /workspace "git status"

# Run make in /vagrant
./scripts/vagrant-ssh standard-devenv --workdir /vagrant "make build"

# Run tests in specific directory
./scripts/vagrant-ssh example-project --workdir /app "npm test"
```

#### Start Interactive Shell in Directory

```bash
# Open shell in /workspace
./scripts/vagrant-ssh standard-devenv --workdir /workspace

# Open shell in project directory
./scripts/vagrant-ssh example-project --workdir /opt/myapp
```

This is equivalent to:

```bash
cd packages/programs/example-project
vagrant ssh -c "cd /opt/myapp && exec \$SHELL -l"
```

### How VM Discovery Works

The script searches all Vagrantfiles under `packages/` and matches the box name against:

1. **VirtualBox provider name** (`vb.name`)
2. **VM hostname** (`config.vm.hostname`)

Example Vagrantfile that matches "standard-devenv":

```ruby
Vagrant.configure("2") do |config|
  config.vm.hostname = "standard-devenv"
  
  config.vm.provider "virtualbox" do |vb|
    vb.name = "standard-devenv"
  end
end
```

### Adding to PATH

For convenience, add the scripts directory to your PATH:

#### Bash/Zsh

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/devx/scripts"
```

#### Fish

```fish
set -Ua fish_user_paths /path/to/devx/scripts
```

Then use it directly:

```bash
vagrant-ssh standard-devenv
vagrant-ssh base-rocky9 --workdir /workspace
```

### Examples

#### Development Workflow

```bash
# Start your dev environment
./scripts/vagrant-ssh standard-devenv --workdir /workspace

# Inside the VM:
git pull
make build
make test
```

#### Quick Status Checks

```bash
# Check all VMs without navigating to directories
./scripts/vagrant-ssh base-rocky8 "uptime"
./scripts/vagrant-ssh base-rocky9 "uptime"
./scripts/vagrant-ssh standard-devenv "docker ps"
./scripts/vagrant-ssh example-project "systemctl status myapp"
```

#### Running CI Tasks

```bash
# Run linting
./scripts/vagrant-ssh example-project --workdir /workspace "npm run lint"

# Run tests
./scripts/vagrant-ssh example-project --workdir /workspace "npm test"

# Build documentation
./scripts/vagrant-ssh standard-devenv --workdir /docs "make html"
```

### Troubleshooting

#### "Could not find a Vagrantfile for VM"

**Cause**: The script couldn't find a Vagrantfile matching the box name.

**Solutions**:

1. Verify the box name is correct (case-sensitive)
2. Check that the Vagrantfile exists under `packages/`
3. Ensure the Vagrantfile has `vb.name` or `config.vm.hostname` set

List all available VMs:

```bash
find packages/ -name Vagrantfile -exec grep -H "vb.name\|vm.hostname" {} \;
```

#### Permission Denied

**Cause**: Script is not executable.

**Solution**:

```bash
chmod +x scripts/vagrant-ssh
```

#### VM Not Running

**Cause**: The Vagrant VM is not started.

**Solution**:

```bash
# Find the VM directory first
find packages/ -name Vagrantfile -path "*/base-rocky9/*"

# Navigate and start it
cd packages/base/images/rocky9
vagrant up
```

Or let the script tell you the path:

```bash
./scripts/vagrant-ssh base-rocky9
# Output shows: "Found VM at: /path/to/packages/base/images/rocky9"
```

### Advanced Usage

#### Piping Commands

```bash
# Pipe local file to VM command
cat config.json | ./scripts/vagrant-ssh standard-devenv "jq '.'"

# Save VM output locally
./scripts/vagrant-ssh standard-devenv "cat /var/log/app.log" > local-app.log
```

#### Combining with Other Tools

```bash
# Use with watch
watch -n 5 './scripts/vagrant-ssh standard-devenv "docker stats --no-stream"'

# Use with xargs
echo "base-rocky9 standard-devenv" | xargs -n1 ./scripts/vagrant-ssh -c "uptime"
```

#### Script Integration

```bash
#!/bin/bash
# deploy.sh - Example deployment script

# Build application
./scripts/vagrant-ssh example-project --workdir /workspace "make build"

# Run tests
if ./scripts/vagrant-ssh example-project --workdir /workspace "make test"; then
    echo "Tests passed, deploying..."
    ./scripts/vagrant-ssh example-project --workdir /workspace "make deploy"
else
    echo "Tests failed, aborting deployment"
    exit 1
fi
```

## Best Practices

### Use vagrant-ssh for Ad-Hoc Operations

```bash
# Good: Quick checks from anywhere
./scripts/vagrant-ssh standard-devenv "docker ps"

# Less ideal: Navigation overhead
cd packages/organization/spins/standard
vagrant ssh -c "docker ps"
cd -
```

### Use Standard vagrant ssh for Provisioning Workflows

When working within a specific box's directory for extended periods:

```bash
cd packages/programs/my-project
vagrant up
vagrant ssh
# ... do extended work ...
vagrant halt
```

### Combine Both Approaches

```bash
# From project root, check status
./scripts/vagrant-ssh my-project "systemctl status myapp"

# If issues found, go deep
cd packages/programs/my-project
vagrant ssh
# ... debug interactively ...
```

## See Also

- [Common Tasks](common-tasks.md) - Frequently performed operations
- [Troubleshooting](troubleshooting.md) - Solutions to common issues
- [Configuration](configuration.md) - Environment configuration guide
