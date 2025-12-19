# FOSS Package Management

Administrator guide for managing the FOSS package ecosystem.

## Overview

The FOSS ecosystem provides vetted open-source packages with:

- Security scanning
- License compliance
- Approval workflows
- Internal mirrors

## Package Lifecycle

### 1. Submission

Users submit via CLI:
```bash
foss-cli submit --name package --version 1.0.0 --ecosystem pypi
```

### 2. Automated Security Scan

Runs automatically:
```bash
cd packages/organization/foss-packages
./scripts/security-scan.sh package
```

### 3. License Review

Check against approved licenses:
```bash
cat licenses/approved-licenses.yml
```

### 4. Manual Review

- Review security scan results
- Check license compatibility
- Verify package authenticity
- Test functionality

### 5. Approval/Rejection

```bash
# Approve
./scripts/approve-package.sh package

# Reject
foss-cli reject package "Reason"
```

## Security Policies

Edit `packages/organization/foss-packages/security/policies.yml`:

```yaml
vulnerability_thresholds:
  critical: 0  # Block if any critical
  high: 2      # Block if >2 high
  medium: 10
  low: 50

scan_tools:
  - trivy
  - grype
  - osv-scanner
```

## License Management

Approved licenses in `licenses/approved-licenses.yml`:

```yaml
approved_licenses:
  - MIT
  - Apache-2.0
  - BSD-3-Clause

conditional_licenses:
  - GPL-3.0  # Requires review

prohibited_licenses:
  - AGPL-3.0
```

## Internal Mirrors

Sync packages to internal mirrors:

```bash
./scripts/sync-mirrors.sh
```

Configures:

- PyPI mirror
- NPM registry
- Maven repository
- Docker registry

## Monitoring

- Daily security scans
- License compliance checks
- Mirror synchronization
- Usage metrics

## See Also

- [FOSS Packages](../foss-packages.md)
- [Security Configuration](security-config.md)
- [REST API](../api/rest-api.md)
