# Base Layer

The base layer provides hardened OS images that serve as the foundation for all environments.

## Purpose

Provides security-hardened, minimal OS images suitable for:

- Air-gapped deployments
- Secure development environments
- Consistent base platform
- Compliance requirements

## Components

### OS Images

**Supported Distributions:**

- **Rocky Linux 10**: Primary supported distribution (recommended)
- **Rocky Linux 9**: Stable production-ready release
- **Rocky Linux 8**: Legacy support for existing deployments

All distributions include:

- Security hardening with CIS benchmarks
- Minimal package set
- SELinux enforcing mode

### Security Configuration

- SSH hardening (key-only, no root)
- Firewall enabled
- Audit logging
- Automatic security updates

### Core Packages

- vim, git, curl, wget
- Python 3
- Development tools
- System utilities

## Directory Structure

```
packages/base/
├── images/
│   ├── rocky8/           # Rocky Linux 8 base image
│   ├── rocky9/           # Rocky Linux 9 base image
│   └── rocky10/          # Rocky Linux 10 base image
├── ansible/
│   ├── group_vars/       # Base configuration
│   ├── playbooks/        # Setup playbooks
│   └── roles/            # Security roles
├── tests/               # Verification tests
└── artifacts/          # Built images (.box files)
```

## Configuration

`packages/base/ansible/group_vars/all.yml`:

```yaml
base_security_hardening:
  selinux_mode: "enforcing"
  ssh_password_auth: false
  firewall_enabled: true

base_timezone: "UTC"

base_packages:
  - vim
  - git
  - curl
```

## Building

```bash
# Build Rocky Linux 10 (default)
make build-base
# or explicitly
make build-base-rocky10

# Build Rocky Linux 9
make build-base-rocky9

# Build Rocky Linux 8
make build-base-rocky8

# Build all base images
make build-all
```

See [Building Base Images](../admin/building-base-images.md) for detailed instructions.

## See Also

- [Architecture Overview](../architecture.md)
- [Organization Layer](org-layer.md)
- [Security Configuration](../admin/security-config.md)
