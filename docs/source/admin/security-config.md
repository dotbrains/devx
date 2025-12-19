# Security Configuration

Administrator guide for security hardening and configuration.

## Base Layer Security

### SELinux

Enforcing mode by default:

```yaml
# packages/base/ansible/group_vars/all.yml
base_security_hardening:
  selinux_mode: "enforcing"
```

### SSH Hardening

```yaml
ssh_config:
  password_auth: false
  root_login: false
  port: 22
  allowed_users: ["vagrant"]
```

### Firewall

```yaml
firewall:
  enabled: true
  default_zone: "public"
  allowed_services:
    - ssh
    - http
    - https
```

## Organization Layer Security

### FOSS Package Scanning

Security scan configuration:

```yaml
# packages/organization/foss-packages/security/policies.yml
vulnerability_thresholds:
  critical: 0
  high: 2
  medium: 10
  low: 50
```

### License Compliance

Only approved licenses:

```yaml
approved_licenses:
  - MIT
  - Apache-2.0
  - BSD-3-Clause
```

## Secrets Management

### Ansible Vault

```bash
# Create vault
ansible-vault create secrets.yml

# Edit vault
ansible-vault edit secrets.yml

# Encrypt string
ansible-vault encrypt_string 'secret' --name 'var_name'
```

### Environment Variables

Never commit secrets:

```bash
export API_KEY=$(vault read -field=key secret/api)
```

## Audit Logging

Enabled by default:

```yaml
audit:
  enabled: true
  rules:
    - "-w /etc/passwd -p wa"
    - "-w /etc/shadow -p wa"
```

## Security Updates

Automatic updates:

```yaml
automatic_updates:
  enabled: true
  reboot: false
  security_only: true
```

## Compliance

### CIS Benchmarks

Base images follow CIS Rocky Linux 9 benchmarks.

### Airgap Support

- Internal package mirrors
- No external dependencies
- Offline installation support

## Security Monitoring

- Daily vulnerability scans
- Audit log review
- Access monitoring
- Update tracking

## See Also

- [Building Base Images](building-base-images.md)
- [FOSS Package Management](foss-packages.md)
- [Architecture](../architecture.md)
