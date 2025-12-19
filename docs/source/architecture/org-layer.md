# Organization Layer

The organization layer provides shared tools, packages, and configurations for the entire organization.

## Purpose

Provides:

- Curated app store with developer tools
- FOSS package management system
- Organization-specific spins
- Shared configurations and standards

## Components

### App Store

- 17+ curated developer tools
- Version controlled
- Security vetted
- Highly configurable

Tools include: Docker, Kubernetes (kubectl, helm, k9s), Python, Node.js, Git, and more.

### FOSS Package Ecosystem

- Package registry with approval workflows
- Security scanning (Trivy, Grype, OSV)
- License compliance tracking
- Internal mirrors (PyPI, NPM, Maven, Docker)
- REST API and CLI tool

### Organization Spins

Pre-configured variants:

- Standard development environment
- Data science environment
- DevOps tooling
- Custom organization-specific setups

## Directory Structure

```
packages/organization/
├── app-store/
│   └── catalog.yml        # Available applications
├── foss-packages/
│   ├── registry/          # Package registry
│   ├── security/          # Security policies
│   ├── licenses/          # License management
│   ├── api/               # REST API
│   ├── cli/               # CLI tool
│   └── scripts/           # Management scripts
├── spins/
│   └── standard/          # Standard organization spin
├── ansible/
│   └── group_vars/
│       └── apps.yml       # App configurations
└── tests/               # Verification tests
```

## Configuration

`packages/organization/ansible/group_vars/apps.yml`:

```yaml
apps:
  docker:
    enabled: true
    version: "24.0"
  
  python:
    enabled: true
    version: "3.11"
```

## Usage

Programs inherit from organization layer and can:

- Enable/disable apps
- Override versions
- Add custom configuration

## See Also

- [Architecture Overview](../architecture.md)
- [Base Layer](base-layer.md)
- [Program Layer](program-layer.md)
- [App Store Guide](../app-store.md)
- [FOSS Packages](../foss-packages.md)
