# DevX Scripts

Utility scripts for working with the Developer Environment Framework.

## vagrant-ssh

Smart wrapper for `vagrant ssh` that provides enhanced functionality for managing Vagrant VMs.

### Features

- **Auto-discovery**: Automatically finds the correct Vagrant box directory by name
- **Ctrl+C protection**: Prevents accidental SSH session termination with Ctrl+C
- **Working directory support**: Change to a specific directory before executing commands
- **Interactive and command modes**: Support for both interactive shells and one-off commands

### Usage

```bash
vagrant-ssh <box-name> [OPTIONS] [command]
```

#### Arguments

- `box-name` - Name of the Vagrant VM (e.g., `base-rocky10`, `standard-devenv`)
- `command` - Optional command to execute in the VM

#### Options

- `--workdir <dir>` - Change to this directory in the VM before executing command
- `-h, --help` - Show help message

### Examples

#### Interactive SSH Session

Connect to a VM interactively:

```bash
./scripts/vagrant-ssh base-rocky8
./scripts/vagrant-ssh base-rocky9
./scripts/vagrant-ssh base-rocky10
```

#### Execute a Single Command

Run a command in the VM and exit:

```bash
./scripts/vagrant-ssh standard-devenv "ls -la"
./scripts/vagrant-ssh base-rocky8 "systemctl status"
./scripts/vagrant-ssh base-rocky10 "docker ps"
```

#### Change Directory and Execute

Execute a command in a specific directory:

```bash
./scripts/vagrant-ssh standard-devenv --workdir /workspace "git status"
./scripts/vagrant-ssh standard-devenv --workdir /vagrant "make test"
```

#### Start Interactive Shell in Specific Directory

Open a shell in a specific directory:

```bash
./scripts/vagrant-ssh standard-devenv --workdir /workspace
```

### How It Works

1. **Box Discovery**: The script searches all Vagrantfiles under `packages/` to find one matching the specified box name
2. **Directory Change**: Automatically changes to the directory containing the matching Vagrantfile
3. **SSH Connection**: Executes the appropriate `vagrant ssh` command with your options
4. **Signal Handling**: Traps SIGINT (Ctrl+C) to prevent accidental disconnection

### VM Name Resolution

The script finds VMs by matching the box name against:

- `vb.name` field in the Vagrantfile (VirtualBox provider name)
- `config.vm.hostname` field in the Vagrantfile (VM hostname)

For example, these Vagrantfiles would be found:

```ruby
# Matches: base-rocky10
config.vm.hostname = "base-rocky10"
config.vm.provider "virtualbox" do |vb|
  vb.name = "base-rocky10"
end
```

### Adding to PATH

For easier access, add the scripts directory to your PATH:

**Bash/Zsh:**
```bash
echo 'export PATH="$PATH:/path/to/devx/scripts"' >> ~/.bashrc
```

**Fish:**
```fish
set -Ua fish_user_paths /path/to/devx/scripts
```

Then use it directly:

```bash
vagrant-ssh standard-devenv
```

## Troubleshooting

### "Could not find a Vagrantfile for VM"

This error means the script couldn't find a matching VM. Check:

1. The box name is correct (case-sensitive)
2. The Vagrantfile exists under `packages/`
3. The Vagrantfile has a `vb.name` or `config.vm.hostname` matching your box name

List all available VMs:

```bash
find packages/ -name Vagrantfile -exec grep -l "vb.name\|vm.hostname" {} \;
```

### Script Not Executable

If you get a "Permission denied" error:

```bash
chmod +x scripts/vagrant-ssh
```

## Contributing

When adding new scripts to this directory:

1. Make them executable: `chmod +x scripts/your-script`
2. Add a shebang line: `#!/usr/bin/env bash`
3. Include usage documentation in the script header
4. Update this README with examples
5. Follow the existing code style and patterns
