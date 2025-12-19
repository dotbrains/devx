# CLI Tool

Command-line interface for the FOSS package management system.

## Installation

```bash
cd packages/organization/foss-packages
./scripts/install-foss-cli.sh
```

This installs the `foss-cli` command globally.

## Commands

### search

Search for packages in the registry.

```bash
foss-cli search <query> [options]
```

**Options:**

- `-e, --ecosystem <name>`: Filter by ecosystem (pypi, npm, maven, docker)
- `--json`: Output as JSON

**Examples:**

```bash
# Search for Flask packages
foss-cli search flask

# Search in specific ecosystem
foss-cli search express --ecosystem npm

# JSON output
foss-cli search requests --json
```

### info

Get detailed information about a package.

```bash
foss-cli info <package-name>
```

**Examples:**

```bash
foss-cli info flask
foss-cli info requests
```

**Output:**

```
Package: flask
Version: 2.3.0
Ecosystem: pypi
Status: approved
License: BSD-3-Clause
Description: A lightweight WSGI web application framework
Homepage: https://flask.palletsprojects.com
Repository: https://github.com/pallets/flask
```

### security

Check security scan results for a package.

```bash
foss-cli security <package-name>
```

**Examples:**

```bash
foss-cli security flask
```

**Output:**

```
Security Scan Results for: flask 2.3.0
Scan Date: 2024-01-16 10:00:00
Status: ✓ PASSED

Vulnerabilities:
  Critical: 0
  High: 0
  Medium: 0
  Low: 0

Scanned with: trivy, grype, osv-scanner
```

### submit

Submit a new package for review.

```bash
foss-cli submit [options]
```

**Options:**

- `-n, --name <name>`: Package name (required)
- `-v, --version <version>`: Package version (required)
- `-e, --ecosystem <ecosystem>`: Ecosystem (required)
- `-l, --license <license>`: License
- `-d, --description <desc>`: Description
- `--homepage <url>`: Homepage URL
- `--repository <url>`: Repository URL

**Examples:**

```bash
# Interactive mode
foss-cli submit

# With options
foss-cli submit \
  --name requests \
  --version 2.31.0 \
  --ecosystem pypi \
  --license Apache-2.0
```

### list

List all packages in the registry.

```bash
foss-cli list [options]
```

**Options:**

- `-s, --status <status>`: Filter by status (pending, approved, rejected)
- `-e, --ecosystem <ecosystem>`: Filter by ecosystem
- `--json`: Output as JSON

**Examples:**

```bash
# List all packages
foss-cli list

# List approved packages only
foss-cli list --status approved

# List PyPI packages
foss-cli list --ecosystem pypi
```

### approve

Approve a pending package (admin only).

```bash
foss-cli approve <package-name>
```

**Examples:**

```bash
foss-cli approve requests
```

### reject

Reject a pending package (admin only).

```bash
foss-cli reject <package-name> [reason]
```

**Examples:**

```bash
foss-cli reject some-package "Security vulnerabilities found"
```

## Global Options

- `-h, --help`: Show help
- `-v, --version`: Show version
- `--verbose`: Verbose output
- `--json`: JSON output (where applicable)

## Authentication

The CLI supports API token authentication for protected operations.

### Setup Authentication

1. **Generate a token:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

2. **Set environment variable:**
```bash
export FOSS_API_TOKEN="your-generated-token"
```

3. **Use CLI commands:**
```bash
# Protected operations (require token)
foss-cli submit package 1.0.0 --type pypi

# Public operations (no token required)
foss-cli search package
foss-cli list
```

### Alternative: Use --token Flag

```bash
foss-cli --token "your-token" submit package 1.0.0 --type pypi
```

**Protected Commands** (require token when server auth is enabled):

- `submit` - Submit packages
- `approve` - Approve packages
- `reject` - Reject packages

**Public Commands** (no token required):

- `search` - Search packages
- `list` - List packages
- `info` - Package details
- `security` - Security scans

📖 **See [Authentication Guide](../authentication.md) for complete setup instructions.**

## Configuration

### Environment Variables

- `FOSS_API_URL`: API base URL (default: `http://localhost:8000`)
- `FOSS_API_TOKEN`: API authentication token
- `FOSS_VERBOSE`: Enable verbose mode
- `FOSS_JSON`: Enable JSON output

**Example:**

```bash
export FOSS_API_URL=http://api.example.com
export FOSS_API_TOKEN="your-generated-token"
export FOSS_VERBOSE=1
foss-cli search flask
```

### Config File

Create `~/.foss-cli/config.yml`:

```yaml
api_url: http://localhost:8000
default_ecosystem: pypi
verbose: false
json_output: false
```

## Examples

### Search Workflow

```bash
# Search for a package
foss-cli search flask

# Get package details
foss-cli info flask

# Check security status
foss-cli security flask
```

### Submit Workflow with Authentication

```bash
# Set up authentication first
export FOSS_API_TOKEN="your-generated-token"

# Submit a new package
foss-cli submit \
  --name mypackage \
  --version 1.0.0 \
  --ecosystem pypi \
  --license MIT

# Check submission status
foss-cli info mypackage
```

### Admin Workflow

```bash
# List pending packages
foss-cli list --status pending

# Review package
foss-cli info somepackage
foss-cli security somepackage

# Approve or reject
foss-cli approve somepackage
# or
foss-cli reject somepackage "Reason for rejection"
```

## Output Formats

### Table Format (Default)

```bash
foss-cli list
```

Output:
```
Packages (15 total)
┌──────────┬─────────┬───────────┬──────────┬──────────────┐
│ Name     │ Version │ Ecosystem │ Status   │ License      │
├──────────┼─────────┼───────────┼──────────┼──────────────┤
│ flask    │ 2.3.0   │ pypi      │ approved │ BSD-3-Clause │
│ requests │ 2.31.0  │ pypi      │ approved │ Apache-2.0   │
└──────────┴─────────┴───────────┴──────────┴──────────────┘
```

### JSON Format

```bash
foss-cli list --json
```

```json
{
  "packages": [
    {
      "name": "flask",
      "version": "2.3.0",
      "ecosystem": "pypi",
      "status": "approved",
      "license": "BSD-3-Clause"
    }
  ],
  "total": 1
}
```

## Troubleshooting

### Command Not Found

Ensure the CLI is installed:
```bash
cd packages/organization/foss-packages
./scripts/install-foss-cli.sh
```

### API Connection Error

Check API is running:
```bash
curl http://localhost:8000/api/v1/packages
```

Set correct API URL:
```bash
export FOSS_API_URL=http://your-api-url:8000
```

### Permission Denied

Ensure CLI is executable:
```bash
chmod +x ~/.local/bin/foss-cli
```

### Authentication Errors

**401 Unauthorized:**
```bash
# Generate and set token
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
export FOSS_API_TOKEN="your-generated-token"
```

**403 Forbidden:**
```bash
# Verify token is correct
echo $FOSS_API_TOKEN
# Contact admin for valid token
```

**Token not being used:**
```bash
# Check token is set
echo $FOSS_API_TOKEN

# If empty, export it
export FOSS_API_TOKEN="your-token-here"
```

## See Also

- [REST API](rest-api.md) - HTTP API documentation
- [API Reference](../api-reference.md) - Overview
- [FOSS Packages](../foss-packages.md) - Package management
