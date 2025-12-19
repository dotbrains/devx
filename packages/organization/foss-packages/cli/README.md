# FOSS Package CLI

Command-line interface for managing packages in the FOSS ecosystem.

## Installation

```bash
cd packages/organization/foss-packages
./scripts/install-foss-cli.sh
```

Or install manually:

```bash
cd cli
python3 -m venv venv
source venv/bin/activate
pip install -e .
```

## Usage

### Activate CLI Environment

```bash
source cli/venv/bin/activate
```

### Search for Packages

```bash
# Basic search
foss-cli search requests

# Filter by type
foss-cli search flask --type pypi

# Filter by status
foss-cli search nginx --status approved
```

### Get Package Information

```bash
# Get all versions
foss-cli info requests

# Get specific version
foss-cli info requests 2.31.0

# JSON output
foss-cli info flask --json
```

### View Security Scans

```bash
# Latest scan for package
foss-cli security requests

# Specific version
foss-cli security flask 3.0.0

# JSON output for programmatic use
foss-cli security axios --json
```

### Submit New Package

```bash
# Basic submission
foss-cli submit axios 1.6.2 --type npm

# With description
foss-cli submit requests 2.31.0 --type pypi --description "HTTP library for Python"

# With upstream URL
foss-cli submit nginx 1.25.3 --type container \
  --upstream-url "https://hub.docker.com/_/nginx"
```

### List Packages

```bash
# List all approved packages
foss-cli list

# Filter by type
foss-cli list --type pypi

# Show pending packages
foss-cli list --status pending

# Combine filters
foss-cli list --type npm --status approved
```

### Approve/Reject Packages

```bash
# Approve a package
foss-cli approve requests 2.31.0

# Approve with notes
foss-cli approve flask 3.0.0 --notes "Security review complete"

# Reject a package
foss-cli reject vulnerable-pkg 1.0.0 --reason "Critical CVE found"
```

## Global Options

```bash
# Specify API URL
foss-cli --api-url http://api.example.com search requests

# Verbose output
foss-cli -v search flask

# JSON output
foss-cli --json info requests
```

## Authentication

The CLI supports API token authentication for protected operations (like submitting packages).

📖 **Quick Start**: See [AUTH_QUICKSTART.md](./AUTH_QUICKSTART.md) for a 3-step setup guide.

### Setup Authentication

#### 1. Generate a Token

Generate a secure token using Python:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Example output:
```
x7jK9mN2pQ4rT8vW1yZ3bD5fH6gJ8kL0nM2oP4qR6sT8uV0wX2yZ4aB6cD8eF0g
```

#### 2. Configure Token

Set the token as an environment variable:

```bash
# Add to ~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish
export FOSS_API_TOKEN="x7jK9mN2pQ4rT8vW1yZ3bD5fH6gJ8kL0nM2oP4qR6sT8uV0wX2yZ4aB6cD8eF0g"

# Or for current session only
export FOSS_API_TOKEN="your-token-here"
```

#### 3. Use Token in Commands

**Option 1: Environment Variable (Recommended)**
```bash
export FOSS_API_TOKEN="your-token-here"
foss-cli submit axios 1.6.2 --type npm
```

**Option 2: Command Line Flag**
```bash
foss-cli --token "your-token-here" submit axios 1.6.2 --type npm
```

**Option 3: Per-Command**
```bash
FOSS_API_TOKEN="your-token-here" foss-cli submit axios 1.6.2 --type npm
```

### Authentication Behavior

- **Protected Operations**: `submit`, `approve`, `reject` (require token when server auth is enabled)
- **Public Operations**: `search`, `info`, `list`, `security` (no token required)
- **Warning**: CLI will warn if no token is provided for protected operations

### Examples with Authentication

```bash
# Submit package with token
export FOSS_API_TOKEN="your-token"
foss-cli submit requests 2.31.0 --type pypi

# Alternative: inline token
foss-cli --token "your-token" submit flask 3.0.0 --type pypi

# Public operations don't need token
foss-cli search requests
foss-cli info flask 3.0.0
```

## Configuration

### Environment Variables

```bash
# API Connection
export FOSS_API_URL="http://localhost:8000"

# Authentication
export FOSS_API_TOKEN="your-api-token-here"

# Output Options
export FOSS_VERBOSE="true"
export FOSS_JSON="false"
```

### Create Global Alias

```bash
# Add to ~/.bashrc or ~/.zshrc
alias foss='source /path/to/cli/venv/bin/activate && foss-cli'

# Or create symlink
sudo ln -s /path/to/cli/venv/bin/foss-cli /usr/local/bin/foss-cli
```

## Examples

### Complete Workflow with Authentication

```bash
# 0. Set up authentication (first time only)
export FOSS_API_TOKEN="your-generated-token"

# 1. Search for a package
foss-cli search pandas

# 2. Get detailed information
foss-cli info pandas 2.1.0

# 3. Check security scans
foss-cli security pandas 2.1.0

# 4. Submit for approval if not found (requires auth)
foss-cli submit pandas 2.1.0 --type pypi \
  --description "Data analysis library" \
  --upstream-url "https://pypi.org/project/pandas/"

# 5. Check submission status
foss-cli list --status pending

# 6. Approve after review (requires auth)
foss-cli approve pandas 2.1.0 --notes "Passed security review"
```

### Integration with Scripts

```bash
# Check if package is approved
if foss-cli info requests 2.31.0 --json | jq -e '.[] | select(.status=="approved")' > /dev/null; then
  echo "Package is approved"
else
  echo "Package not approved"
fi

# Get all pending packages
foss-cli list --status pending --json | jq '.[] | {name, version}'

# Batch submit packages
cat packages.txt | while read name version type; do
  foss-cli submit "$name" "$version" --type "$type"
done
```

## Development

### Running Tests

```bash
cd cli
pytest tests/
```

### Building Distribution

```bash
cd cli
python setup.py sdist bdist_wheel
```

## Troubleshooting

### CLI Not Found

```bash
# Ensure virtual environment is activated
source cli/venv/bin/activate

# Verify installation
which foss-cli
```

### API Connection Error

```bash
# Check API is running
curl http://localhost:8000/health

# Set correct API URL
export FOSS_API_URL="http://your-api-url:8000"
```

### Permission Denied on Scripts

```bash
# Make scripts executable
chmod +x scripts/*.sh
chmod +x cli/foss-cli
```

### Authentication Errors

#### 401 Unauthorized
```
Error: 401 Client Error: Unauthorized
```

**Solution**: Add API token
```bash
# Generate token
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Set token
export FOSS_API_TOKEN="your-generated-token"
```

#### 403 Forbidden
```
Error: 403 Client Error: Forbidden
```

**Solution**: Token is invalid. Get a new token from your administrator or regenerate:
```bash
# Verify token is set
echo $FOSS_API_TOKEN

# Check token matches server configuration
# Contact admin if needed
```

#### Token Not Being Used
```
Warning: No API token provided. Authentication may be required.
```

**Solution**: Ensure token is exported in current shell session
```bash
# Check if token is set
echo $FOSS_API_TOKEN

# If empty, export it
export FOSS_API_TOKEN="your-token-here"

# Verify it's working
foss-cli submit test 1.0.0 --type pypi
```

## Command Reference

| Command | Description |
|---------|-------------|
| `search <query>` | Search for packages |
| `info <name> [version]` | Get package details |
| `security <name> [version]` | View security scans |
| `submit <name> <version> --type <type>` | Submit new package |
| `list` | List all packages |
| `approve <name> <version>` | Approve package |
| `reject <name> <version> --reason <reason>` | Reject package |

## Help

```bash
# General help
foss-cli --help

# Command-specific help
foss-cli search --help
foss-cli submit --help
```
