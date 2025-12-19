# Organization Layer (Tier 2)

Organization-wide developer tools, app store, and standardized configurations that extend the base layer.

## Purpose

This layer provides:
- **App Store**: Curated, configurable developer tools
- **Security-Vetted Packages**: Internal FOSS ecosystem
- **Organization Spins**: Customized base images for specific use cases
- **Shared Resources**: Common libraries and utilities

## Contents

### App Store
A catalog of installable developer tools, each highly configurable:
- IDEs (VSCode, IntelliJ, Eclipse)
- Language runtimes (Python, Node.js, Go, Rust)
- Container tools (Docker, Podman, Kubernetes)
- Database clients
- Build tools
- Security scanners

### FOSS Ecosystem
Internal repository of vetted open source packages:
- Security scanning and approval workflows
- Version pinning and updates
- License compliance tracking
- Vulnerability monitoring

### Organization Spins
Pre-configured variants of base images:
- Standard Developer Workstation
- DevSecOps Environment
- Data Science Workstation
- Cloud Native Development

## Directory Structure

```
organization/
├── app-store/
│   ├── catalog.yml           # App definitions
│   ├── apps/                 # Individual app roles
│   └── manifests/            # App manifests
├── foss-packages/
│   ├── registry/             # Package registry
│   ├── security/             # Security scan results
│   └── mirrors/              # Package mirrors
├── spins/
│   ├── standard/             # Standard developer spin
│   ├── devsecops/            # DevSecOps spin
│   └── datascience/          # Data science spin
├── ansible/
│   ├── roles/                # Organization roles
│   ├── playbooks/            # Organization playbooks
│   └── group_vars/           # Organization variables
└── docs/                     # Organization documentation
```

## Using the App Store

### Installing Apps

```bash
cd spins/standard
vagrant up
vagrant ssh
app-store install vscode docker kubectl
```

### Configuring Apps

Edit `ansible/group_vars/apps.yml`:

```yaml
app_store_enabled: true
app_store_auto_update: false

apps:
  vscode:
    enabled: true
    version: "1.85.0"
    extensions:
      - ms-python.python
      - golang.go
  docker:
    enabled: true
    version: "24.0"
    compose: true
```

## Creating a New Spin

```bash
cp -r spins/standard spins/my-spin
cd spins/my-spin
# Edit Vagrantfile and ansible configs
vagrant up
```

## FOSS Package Management

### Adding a Package

```bash
cd foss-packages
./scripts/add-package.sh <package-name> <version>
./scripts/security-scan.sh <package-name>
```

### Package Approval Workflow

1. Submit package request
2. Automated security scanning
3. License compliance check
4. Security team review
5. Approval and publishing
