# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

DevX is a layered, extensible framework for building secure, customizable developer environments using Ansible and Vagrant. It follows a three-tier architecture:

1. **Base Layer (Tier 1)**: Foundation images and core tooling (`packages/base/`)
2. **Organization Layer (Tier 2)**: Organization-wide developer tools and app store (`packages/organization/`)
3. **Program Layer (Tier 3)**: Program/project-specific customizations (`packages/programs/`)

Each tier inherits and extends the previous layer through Ansible variable overrides.

## Common Commands

### Building Base Images

```bash
# Default (Rocky 10) - uses auto-detected provider
make build-base-rocky10

# Build specific version
make build-base-rocky9
make build-base-rocky8  # x86_64 only, not compatible with ARM64

# Build all compatible images for your architecture
make build-all
```

The Makefile auto-detects your provider (Parallels on Apple Silicon, VirtualBox on Intel). Override with:
```bash
make build-base-rocky10 VAGRANT_DEFAULT_PROVIDER=vmware_desktop
```

### Building Organization Spins

```bash
# Build standard organization spin (auto-builds base if needed)
make build-org-standard
```

### Testing

```bash
# Run all tests
make test

# Test specific layers
make test-base
make test-org

# Lint Ansible playbooks
make lint

# Validate all configurations
make validate
```

### Setup and Utilities

```bash
# Create required Ansible inventory files
make setup-ansible-inventory

# Create new program environment
make init-program

# SSH into a VM (using vagrant-ssh utility)
./scripts/vagrant-ssh base-rocky10
./scripts/vagrant-ssh standard-devenv "docker ps"
./scripts/vagrant-ssh standard-devenv --workdir /workspace
```

### Cleanup

```bash
# Clean all Vagrant environments
make clean

# Remove built artifacts
make clean-artifacts
```

## Python Virtual Environment

This project uses a Python virtual environment for Ansible dependencies.

**Automatic Setup (Recommended):**

The virtual environment is automatically created when running `make lint` or `make validate`:

```bash
# Automatically sets up venv if needed and runs linting
make lint

# Automatically sets up venv if needed and runs validation
make validate

# Or manually create the venv
make setup-venv
```

**Manual Setup (Alternative):**

```bash
# Create and activate
python3 -m venv .venv
source .venv/bin/activate  # macOS/Linux

# Install dependencies
pip install ansible ansible-lint
ansible-galaxy collection install -r requirements.yml
```

## Architecture and Key Concepts

### Layer Inheritance Model

Configuration flows through three levels with cascading overrides:

1. **Base defaults**: `packages/base/ansible/group_vars/all.yml`
2. **Organization overrides**: `packages/organization/ansible/group_vars/all.yml`
3. **Program overrides**: `packages/programs/<program>/ansible/group_vars/all.yml`

Each layer marks itself with a file in `/etc/dev-env/` (e.g., `/etc/dev-env/base-layer`, `/etc/dev-env/organization-layer`, `/etc/dev-env/program-layer`). Playbooks verify these markers before provisioning.

### Key Directories

- `packages/base/images/` - Vagrantfiles for base Rocky Linux images (8, 9, 10)
- `packages/base/ansible/` - Base layer Ansible playbooks, roles, and configuration
- `packages/organization/app-store/` - App catalog and installation roles
- `packages/organization/foss-packages/` - Internal FOSS ecosystem with security vetting
- `packages/programs/` - Program-specific environments
- `shared/ansible/` - Shared Ansible configuration
- `scripts/` - Utility scripts (vagrant-ssh, etc.)
- `tests/` - Test suite with syntax, unit, and integration tests

### Base Layer Roles

Located in `packages/base/ansible/roles/`:
- `system-hardening` - Security hardening, SELinux, firewall
- `base-packages` - Essential system packages
- `network-config` - Network configuration
- `user-management` - User and group management
- `monitoring` - Base monitoring setup

### Organization Layer Roles

Located in `packages/organization/ansible/roles/`:
- `app-store-setup` - App catalog initialization
- `foss-repository` - FOSS package ecosystem setup
- `developer-tools` - Organization-wide developer tools
- `organization-security` - Organization security policies
- `organization-monitoring` - Organization monitoring

### App Store System

The organization layer includes an app catalog (`packages/organization/app-store/catalog.yml`) with vetted applications. Each app is:
- Highly configurable via Ansible variables
- Security-vetted
- Installed via dedicated Ansible roles

Default apps include: git, docker, kubectl, helm, containerd, python, nodejs, trivy, and more.

Configure apps in `packages/organization/ansible/group_vars/apps.yml`.

### FOSS Package Ecosystem

The organization layer includes an internal FOSS ecosystem (`packages/organization/foss-packages/`) providing:
- Security-vetted packages with automated scanning
- License compliance checking
- Vulnerability monitoring and CVE tracking
- Internal package mirrors for airgap deployment
- Approval workflows for new packages

Key components:
- `registry/` - Package registry and metadata
- `security/` - Security scanning results and policies
- `licenses/` - License compliance data
- `mirrors/` - Internal package mirrors (PyPI, NPM, Maven, etc.)
- `scripts/` - Management scripts (add-package.sh, security-scan.sh, etc.)
- `api/` - REST API for package management (Python-based)
- `cli/` - CLI tool for package operations

### Provider Support

The framework supports multiple virtualization providers:
- **VirtualBox**: Default for Intel Macs and Linux
- **Parallels Desktop**: Recommended for Apple Silicon Macs
- **VMware Fusion/Workstation**: Cross-platform alternative
- **libvirt/QEMU**: Free option for Apple Silicon

Base images use Bento boxes (`bento/rockylinux-*`) which support all providers.

**ARM64 Compatibility**:
- Rocky Linux 8: NOT compatible with ARM64
- Rocky Linux 9: Compatible
- Rocky Linux 10: Compatible (recommended)

## Development Practices

### Ansible Style

- Follow Ansible best practices
- Use FQCN for built-in modules (e.g., `ansible.builtin.package`)
- 2-space YAML indentation
- Quote strings in YAML
- Use tags for conditional execution (e.g., `security`, `apps`, `monitoring`)

### Ansible Linting

Configuration is in `.ansible-lint` with profile set to "production". Enabled rules include:
- `fqcn-builtins` - Enforce fully qualified collection names
- `no-log-password` - Prevent password exposure in logs

Run linting with:
```bash
source .venv/bin/activate
make lint
```

### Roles Path Configuration

Ansible roles are resolved using paths defined in `ansible.cfg` files at each layer:
- Base: `packages/base/ansible/ansible.cfg`
- Organization: `packages/organization/ansible/ansible.cfg`

Roles can be shared via `shared/ansible/roles/` (referenced in roles_path).

### Adding New Apps to App Store

1. Create the app role in `packages/organization/app-store/apps/<app-name>/`
2. Add app definition to `packages/organization/app-store/catalog.yml`
3. Define default configuration in `packages/organization/ansible/group_vars/apps.yml`
4. Implement the role's `tasks/main.yml`
5. Test the app installation
6. Update documentation

### Creating New Organization Spins

1. Copy the template: `cp -r packages/organization/spins/standard packages/organization/spins/my-spin`
2. Customize the Vagrantfile and Ansible variables
3. Test: `cd packages/organization/spins/my-spin && vagrant up`
4. Document the spin's purpose

### Creating New Programs

Use the Makefile:
```bash
make init-program
# Enter program name when prompted
```

Or manually:
```bash
cp -r packages/programs/templates/basic packages/programs/my-program
```

### Testing Workflow

1. Test Ansible syntax: `make validate`
2. Lint playbooks: `make lint`
3. Run layer-specific tests: `make test-base` or `make test-org`
4. Run full test suite: `make test`

Test scripts are in `tests/` and include:
- Syntax validation
- Unit tests for each layer
- Integration tests for API and CLI
- Shell script syntax checking

### Version Control

This project uses Git. When committing changes:
- Follow conventional commits format: `type(scope): subject`
- Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Update CHANGELOG.md for significant changes
- Include co-author line for Warp: `Co-Authored-By: Warp <agent@warp.dev>`

### Vagrant Box Packaging

After provisioning a VM:
```bash
cd packages/base/images/rocky10
vagrant package --output ../../artifacts/base-rocky10.box
```

Artifacts are stored in `packages/base/artifacts/`.

## Important Notes

- **Architecture Validation**: The Makefile validates ARM64/x86_64 compatibility before building
- **Dependency Management**: Organization spins automatically build missing base images
- **Ansible Inventory**: Required inventory files are auto-created by `make setup-ansible-inventory`
- **Airgap Support**: Designed for airgapped deployments with local repository mirrors
- **Security First**: SELinux enforcing mode, firewall enabled, SSH password auth disabled by default
- **Minimal Base**: Base layer installs only essential packages; customization happens in upper layers
- **Provider Detection**: Makefile auto-detects best provider for your architecture
- **Layer Markers**: Each provisioning layer creates a marker file in `/etc/dev-env/` for validation

## File Patterns

- Vagrantfiles: `packages/*/images/*/Vagrantfile` or `packages/*/spins/*/Vagrantfile`
- Ansible playbooks: `packages/*/ansible/playbooks/*.yml`
- Ansible roles: `packages/*/ansible/roles/*/tasks/main.yml`
- Group variables: `packages/*/ansible/group_vars/all.yml`
- App catalog: `packages/organization/app-store/catalog.yml`
- FOSS registry: `packages/organization/foss-packages/registry/packages.yml`

## CI/CD Pipeline

The repository includes GitHub Actions workflows for automated building, testing, and publishing of Vagrant boxes. See `.github/workflows/README.md` for details.

Boxes are published to GitHub Releases with SHA256 checksums.
