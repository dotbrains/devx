# FOSS Package API

REST API for managing the FOSS package ecosystem, providing programmatic access to package registry, security scans, and license information.

## Features

- **Package Management**: List, search, and submit packages
- **Security Scanning**: Access security scan results and vulnerability reports
- **License Information**: Query license details and compatibility
- **Authentication**: Custom API token authentication for write operations
- **Async Processing**: Background security scanning on package submission
- **OpenAPI Documentation**: Interactive API docs with Swagger UI

## Quick Start

### Local Development

```bash
cd packages/organization/foss-packages/api

# Run the API server
./run.sh
```

The API will be available at:
- API: http://localhost:8000
- Interactive Docs: http://localhost:8000/api/docs
- ReDoc: http://localhost:8000/api/redoc

### Docker Deployment

```bash
cd packages/organization/foss-packages/api

# Start with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## API Endpoints

### Packages

#### List All Packages
```bash
GET /api/v1/packages

# Query parameters:
# - q: Search by name substring
# - type: Filter by type (pypi, npm, maven, container, binary)
# - status: Filter by status (approved, pending, rejected)
# - name: Exact package name
# - version: Exact version

# Examples:
curl "http://localhost:8000/api/v1/packages"
curl "http://localhost:8000/api/v1/packages?type=pypi&status=approved"
curl "http://localhost:8000/api/v1/packages?q=flask"
```

#### Get Package by Name
```bash
GET /api/v1/packages/{pkg_name}?version={version}

# Examples:
curl "http://localhost:8000/api/v1/packages/requests"
curl "http://localhost:8000/api/v1/packages/requests?version=2.31.0"
```

#### Submit New Package
```bash
POST /api/v1/packages
Content-Type: application/json

{
  "name": "requests",
  "version": "2.31.0",
  "type": "pypi",
  "description": "HTTP library for Python",
  "upstream_url": "https://pypi.org/project/requests/",
  "submitter": "dev@example.com"
}

# Example:
curl -X POST "http://localhost:8000/api/v1/packages" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "axios",
    "version": "1.6.2",
    "type": "npm",
    "description": "Promise based HTTP client",
    "upstream_url": "https://www.npmjs.com/package/axios"
  }'
```

Response:
```json
{
  "message": "Package submission accepted",
  "id": "axios-1.6.2",
  "status": "pending",
  "path": "/path/to/pending/axios-1.6.2.yml",
  "queued_scan": true
}
```

### Security Scans

#### List Scans for Package
```bash
GET /api/v1/security/scans/{pkg_name}?version={version}

# Examples:
curl "http://localhost:8000/api/v1/security/scans/requests"
curl "http://localhost:8000/api/v1/security/scans/requests?version=2.31.0"
```

Response:
```json
[
  {
    "scan_id": "requests-2.31.0-20240124-120000",
    "package": "requests",
    "version": "2.31.0",
    "scan_date": "2024-01-24T12:00:00Z",
    "security_score": 95,
    "vulnerabilities": {
      "critical": 0,
      "high": 0,
      "medium": 1,
      "low": 2,
      "total": 3
    },
    "approval_recommended": true,
    "scan_tools": ["trivy", "grype", "osv-scanner"],
    "report_path": "/path/to/report.json"
  }
]
```

### Licenses

#### Get License Information
```bash
GET /api/v1/licenses/{license_name}

# Examples:
curl "http://localhost:8000/api/v1/licenses/MIT"
curl "http://localhost:8000/api/v1/licenses/Apache-2.0"
```

Response:
```json
{
  "name": "MIT",
  "spdx_id": "MIT",
  "category": "permissive",
  "risk_level": "low",
  "commercial_use": true,
  "modification": true,
  "distribution": true,
  "patent_grant": false,
  "notes": "Very permissive, minimal restrictions",
  "compatible_with": ["Apache-2.0", "BSD-2-Clause", "BSD-3-Clause"],
  "incompatible_with": []
}
```

## Authentication

The API supports custom token-based authentication for write operations (like submitting packages).

📖 **See [AUTH_SETUP.md](./AUTH_SETUP.md) for a complete authentication setup guide.**

### Configuration

Authentication is controlled via environment variables:

```bash
# Comma-separated list of valid API tokens
FOSS_API_TOKENS="your-secret-token-1,your-secret-token-2"

# If no tokens are set, authentication is DISABLED (development only)
# FOSS_API_TOKENS=""
```

### Generating Tokens

You can generate secure tokens using Python:

```python
import secrets
token = secrets.token_urlsafe(32)
print(f"Generated token: {token}")
```

Or use the command line:

```bash
# On Linux/Mac
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Using OpenSSL
openssl rand -base64 32
```

### Using API Tokens

Include the API token in the `X-API-Key` header:

```bash
# Submit a package with authentication
curl -X POST "http://localhost:8000/api/v1/packages" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-secret-token-1" \
  -d '{
    "name": "flask",
    "version": "3.0.0",
    "type": "pypi",
    "description": "Lightweight WSGI web application framework"
  }'
```

### Protected vs Public Endpoints

**Protected Endpoints (require authentication):**
- `POST /api/v1/packages` - Submit new packages

**Public Endpoints (no authentication required):**
- `GET /api/v1/packages` - List packages
- `GET /api/v1/packages/{name}` - Get package details
- `GET /api/v1/security/scans/{name}` - Get security scans
- `GET /api/v1/licenses/{name}` - Get license information
- `GET /health` - Health check
- `GET /` - API root

### Authentication Status

Check if authentication is enabled:

```bash
curl http://localhost:8000/
```

Response:
```json
{
  "name": "FOSS Package API",
  "version": "1.0.0",
  "docs": "/api/docs",
  "openapi": "/api/openapi.json",
  "authentication": "enabled"
}
```

## Configuration

Environment variables:

```bash
# API Server
FOSS_API_HOST=0.0.0.0          # API host
FOSS_API_PORT=8000             # API port
FOSS_API_RELOAD=true           # Auto-reload on code changes

# Authentication
FOSS_API_TOKENS="token1,token2"  # Comma-separated API tokens (leave empty to disable)
FOSS_REQUIRE_AUTH=false          # Require authentication for all endpoints

# CORS
FOSS_CORS_ORIGINS="http://localhost:3000,http://localhost:8000"

# Security Scanning
FOSS_SCAN_ON_SUBMIT=true       # Trigger scan on package submission
```

## Python Client Example

```python
import requests

BASE_URL = "http://localhost:8000/api/v1"
API_KEY = "your-secret-token-1"

# Headers for authenticated requests
headers = {
    "X-API-Key": API_KEY
}

# List all approved packages (no auth required)
response = requests.get(f"{BASE_URL}/packages?status=approved")
packages = response.json()
print(f"Found {len(packages)} approved packages")

# Submit a new package (auth required)
package_data = {
    "name": "flask",
    "version": "3.0.0",
    "type": "pypi",
    "description": "Lightweight WSGI web application framework",
    "submitter": "dev@example.com"
}
response = requests.post(
    f"{BASE_URL}/packages",
    json=package_data,
    headers=headers
)
result = response.json()
print(f"Submitted: {result['id']}, Status: {result['status']}")

# Get security scans
response = requests.get(f"{BASE_URL}/security/scans/flask")
scans = response.json()
for scan in scans:
    print(f"Scan {scan['scan_id']}: Score {scan['security_score']}/100")

# Check license compatibility
response = requests.get(f"{BASE_URL}/licenses/MIT")
license_info = response.json()
print(f"MIT License - Risk Level: {license_info['risk_level']}")
print(f"Compatible with: {', '.join(license_info['compatible_with'])}")
```

## JavaScript/TypeScript Client Example

```typescript
const BASE_URL = 'http://localhost:8000/api/v1';
const API_KEY = 'your-secret-token-1';

// List packages (no auth required)
async function listPackages(type?: string) {
  const url = type 
    ? `${BASE_URL}/packages?type=${type}` 
    : `${BASE_URL}/packages`;
  const response = await fetch(url);
  return response.json();
}

// Submit package (auth required)
async function submitPackage(data: any) {
  const response = await fetch(`${BASE_URL}/packages`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-API-Key': API_KEY
    },
    body: JSON.stringify(data)
  });
  return response.json();
}

// Get scans
async function getScans(packageName: string) {
  const response = await fetch(
    `${BASE_URL}/security/scans/${packageName}`
  );
  return response.json();
}

// Usage
const packages = await listPackages('pypi');
console.log(`Found ${packages.length} PyPI packages`);
```

## Development

### Running Tests

```bash
# Install dev dependencies
pip install -r requirements.txt pytest httpx

# Run tests
pytest
```

### Project Structure

```
api/
├── __init__.py           # Package init
├── app.py                # FastAPI application
├── schemas.py            # Pydantic models
├── storage.py            # Data access layer
├── config.py             # Configuration
├── requirements.txt      # Python dependencies
├── Dockerfile            # Docker image
├── docker-compose.yml    # Docker Compose config
├── run.sh                # Startup script
└── README.md             # This file
```

## Production Deployment

### Security Considerations

1. **Authentication**: ✅ Custom API token authentication implemented
2. **Token Management**: Store tokens securely, never commit to version control
3. **CORS**: Restrict to specific origins in production
4. **Rate Limiting**: Consider adding rate limiting middleware for production
5. **HTTPS**: Deploy behind reverse proxy with SSL
6. **Input Validation**: ✅ Already handled by Pydantic
7. **Token Rotation**: Regularly rotate API tokens

### Reverse Proxy (Nginx)

```nginx
server {
    listen 80;
    server_name foss-api.example.com;

    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### Systemd Service

```ini
[Unit]
Description=FOSS Package API
After=network.target

[Service]
Type=simple
User=foss-api
WorkingDirectory=/opt/foss-packages/api
Environment="FOSS_API_HOST=127.0.0.1"
Environment="FOSS_API_PORT=8000"
ExecStart=/opt/foss-packages/api/venv/bin/uvicorn api.app:app --host 127.0.0.1 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

## Monitoring

Health check endpoint:
```bash
curl http://localhost:8000/api/docs
```

Logs are output to stdout/stderr. In production, use a log aggregation service.

## License

MIT License - See [LICENSE](../../../LICENSE)
