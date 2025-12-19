# FOSS Packages

Complete guide to the FOSS package management system.

## Overview

The FOSS package ecosystem provides a vetted repository of open-source packages with security scanning and license compliance.

## Features

- **Security Scanning**: Multiple tools (Trivy, Grype, OSV-Scanner)
- **License Compliance**: Automated tracking and compatibility checks
- **Vulnerability Monitoring**: Real-time CVE detection
- **Authentication**: Token-based API security
- **REST API**: HTTP endpoints for automation
- **CLI Tool**: Command-line interface for easy access

## Quick Start

See the [Getting Started](getting-started.md) guide for installation instructions.

## Authentication

The FOSS package system now includes token-based authentication:

```bash
# Generate token
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Configure API
export FOSS_API_TOKENS="your-token"

# Configure CLI
export FOSS_API_TOKEN="your-token"
```

**Protected Operations:**

- Package submission
- Package approval/rejection

**Public Operations:**

- Package search and listing
- Security scan results
- License information

See the [Authentication Guide](authentication.md) for complete setup instructions.

## Detailed Documentation

For complete documentation:

- [REST API](api/rest-api.md) - HTTP API reference
- [CLI Tool](api/cli-tool.md) - Command-line interface
- [API Reference](api-reference.md) - Quick reference guide
