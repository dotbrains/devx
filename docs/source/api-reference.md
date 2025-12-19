# API Reference

Complete API documentation for the FOSS package management system.

## Overview

The framework provides two interfaces for package management:

- **REST API**: HTTP endpoints for programmatic access
- **CLI Tool**: Command-line interface for interactive use

## REST API

See [REST API Documentation](api/rest-api.md) for complete endpoint reference.

### Base URL

```
http://localhost:8000/api/v1
```

### Quick Reference

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/packages` | GET | List/search packages |
| `/packages/{name}` | GET | Get package details |
| `/packages` | POST | Submit new package |
| `/security/scans/{name}` | GET | Get security scan results |
| `/licenses/{name}` | GET | Get license information |

## CLI Tool

See [CLI Tool Documentation](api/cli-tool.md) for complete command reference.

### Installation

```bash
cd packages/organization/foss-packages
./scripts/install-foss-cli.sh
```

### Quick Reference

```bash
foss-cli search <query>      # Search packages
foss-cli info <name>          # Package details
foss-cli security <name>      # Security status
foss-cli submit               # Submit package
foss-cli list                 # List all packages
```

## Authentication

The API now supports custom token-based authentication for protected operations.

### API Token Authentication

**Setup:**
```bash
# Generate a secure token
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Configure API server
export FOSS_API_TOKENS="your-generated-token"

# Configure CLI
export FOSS_API_TOKEN="your-generated-token"
```

**Protected Operations** (require token):

- `POST /api/v1/packages` - Submit packages

**Public Operations** (no token required):

- `GET /api/v1/packages` - List/search packages
- `GET /api/v1/packages/{name}` - Get package details
- `GET /api/v1/security/scans/{name}` - Security scans
- `GET /api/v1/licenses/{name}` - License info

### Using Authentication

**API Requests:**
```bash
curl -X POST http://localhost:8000/api/v1/packages \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-generated-token" \
  -d '{"name":"package","version":"1.0.0","type":"pypi"}'
```

**CLI Commands:**
```bash
# Set token
export FOSS_API_TOKEN="your-generated-token"

# Or use --token flag
foss-cli --token "your-generated-token" submit package 1.0.0 --type pypi
```

**Authentication Status Codes:**

- `401 Unauthorized` - Missing API token
- `403 Forbidden` - Invalid API token

For more details, see the [Authentication Guide](authentication.md).

## Error Handling

Standard HTTP status codes:

- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized (Missing token)
- `403`: Forbidden (Invalid token)
- `404`: Not Found
- `500`: Server Error

For authentication errors, see [Authentication Guide](authentication.md).

## Further Reading

- [REST API](api/rest-api.md) - Complete HTTP API documentation
- [CLI Tool](api/cli-tool.md) - Command-line interface guide
- [FOSS Packages](foss-packages.md) - Package management overview
