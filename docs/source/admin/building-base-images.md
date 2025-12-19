# Building Base Images

Guide for administrators to build and maintain base OS images.

## Overview

Base images provide the hardened foundation for all environments. They include:

- Security hardened Rocky Linux 8, 9, or 10
- CIS benchmark compliance
- SELinux enforcement
- Minimal package set
- Airgap compatibility

**Supported Distributions:**

- **Rocky Linux 10**: Recommended for new deployments
- **Rocky Linux 9**: Stable production-ready release
- **Rocky Linux 8**: Legacy support for existing infrastructure

## Prerequisites

- Vagrant 2.3+
- VirtualBox 6.1+ (or other provider)
- 20GB+ disk space per image
- 4GB+ RAM
- Rocky Linux 8, 9, or 10 box (automatically downloaded by Vagrant)

## Building the Base Image

### Quick Build

#### Rocky Linux 10 (Recommended)

```bash
make build-base
# or explicitly
make build-base-rocky10
```

This:

1. Creates VM from Rocky 10 base box
2. Applies security hardening
3. Packages as Vagrant box
4. Outputs to `packages/base/artifacts/base-rocky10.box`

#### Rocky Linux 9

```bash
make build-base-rocky9
```

This:

1. Creates VM from Rocky 9 base box
2. Applies security hardening
3. Packages as Vagrant box
4. Outputs to `packages/base/artifacts/base-rocky9.box`

#### Rocky Linux 8

```bash
make build-base-rocky8
```

This:

1. Creates VM from Rocky 8 base box
2. Applies security hardening
3. Packages as Vagrant box
4. Outputs to `packages/base/artifacts/base-rocky8.box`

#### Build All Base Images

```bash
make build-all
```

Builds Rocky 8, 9, and 10 base images.

### Manual Build

#### Rocky Linux 10

```bash
cd packages/base/images/rocky10
vagrant up
vagrant package --output ../../artifacts/base-rocky10.box
```

#### Rocky Linux 9

```bash
cd packages/base/images/rocky9
vagrant up
vagrant package --output ../../artifacts/base-rocky9.box
```

#### Rocky Linux 8

```bash
cd packages/base/images/rocky8
vagrant up
vagrant package --output ../../artifacts/base-rocky8.box
```

## Configuration

Edit `packages/base/ansible/group_vars/all.yml`:

```yaml
# Security Settings
base_security_hardening:
  selinux_mode: "enforcing"
  ssh_password_auth: false
  ssh_root_login: false
  firewall_enabled: true
  
# Timezone
base_timezone: "UTC"

# Packages
base_packages:
  - vim
  - git
  - curl
  - wget
```

## Security Hardening

The base playbook applies:

- **SELinux**: Enforcing mode
- **SSH**: Key-only authentication, no root login
- **Firewall**: Enabled with minimal rules
- **Audit**: Enabled logging
- **Updates**: Latest security patches

## Testing

```bash
make test-base
```

Or manually:

```bash
cd packages/base/tests
ansible-playbook verify-base.yml
```

## Distribution

### Add to Vagrant

```bash
# Rocky Linux 10
vagrant box add base-rocky10 packages/base/artifacts/base-rocky10.box

# Rocky Linux 9
vagrant box add base-rocky9 packages/base/artifacts/base-rocky9.box

# Rocky Linux 8
vagrant box add base-rocky8 packages/base/artifacts/base-rocky8.box
```

### Share with Team

Upload to:

- Internal artifact repository
- Shared network drive
- Vagrant Cloud (if public)

## Maintenance

### Regular Updates

1. Update packages in playbook
2. Rebuild image
3. Test thoroughly
4. Document changes
5. Distribute new version

### Versioning

Use semantic versioning in box metadata:

```json
{
  "name": "base-rocky9",
  "version": "1.2.0",
  "description": "Hardened Rocky 9 base image"
}
```

## Troubleshooting

See [Troubleshooting Guide](../troubleshooting.md#build-issues).

## See Also

- [Architecture](../architecture.md)
- [Security Configuration](security-config.md)
