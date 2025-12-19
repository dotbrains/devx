# REST API

Complete REST API documentation for the FOSS package management system.

## Base URL

```
http://localhost:8000/api/v1
```

## Authentication

The API uses custom token-based authentication for write operations.

### Setup

1. **Generate a token:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

2. **Configure server:**
```bash
export FOSS_API_TOKENS="your-generated-token"
```

3. **Use in requests:**
```bash
curl -H "X-API-Key: your-generated-token" ...
```

### Protected Endpoints

These endpoints require authentication:

- `POST /packages` - Submit packages

### Public Endpoints

These endpoints are public (no auth required):

- `GET /packages` - List/search packages
- `GET /packages/{name}` - Get package details
- `GET /security/scans/{name}` - Security scans
- `GET /licenses/{name}` - License info

📖 **See [Authentication Guide](../authentication.md) for complete setup instructions.**

## Endpoints

### List Packages

**GET** `/packages`

List or search packages in the registry.

**Query Parameters:**

- `search` (string): Search term
- `ecosystem` (string): Filter by ecosystem (pypi, npm, maven, docker)
- `status` (string): Filter by status (pending, approved, rejected)
- `limit` (integer): Max results (default: 100)
- `offset` (integer): Pagination offset

**Example:**

```bash
curl http://localhost:8000/api/v1/packages?search=flask&ecosystem=pypi
```

**Response:**

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
  "total": 1,
  "limit": 100,
  "offset": 0
}
```

### Get Package Details

**GET** `/packages/{name}`

Get detailed information about a specific package.

**Example:**

```bash
curl http://localhost:8000/api/v1/packages/flask
```

**Response:**

```json
{
  "name": "flask",
  "version": "2.3.0",
  "ecosystem": "pypi",
  "status": "approved",
  "license": "BSD-3-Clause",
  "description": "A lightweight WSGI web application framework",
  "homepage": "https://flask.palletsprojects.com",
  "repository": "https://github.com/pallets/flask",
  "submitted_by": "user@example.com",
  "submitted_at": "2024-01-15T10:30:00Z",
  "approved_by": "admin@example.com",
  "approved_at": "2024-01-16T14:20:00Z"
}
```

### Submit Package

**POST** `/packages`

Submit a new package for review.

**Request Body:**

```json
{
  "name": "requests",
  "version": "2.31.0",
  "ecosystem": "pypi",
  "license": "Apache-2.0",
  "description": "HTTP library for Python",
  "homepage": "https://requests.readthedocs.io",
  "repository": "https://github.com/psf/requests",
  "submitted_by": "user@example.com"
}
```

**Example:**

```bash
# With authentication (required if server has auth enabled)
curl -X POST http://localhost:8000/api/v1/packages \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-generated-token" \
  -d '{"name":"requests","version":"2.31.0","ecosystem":"pypi"}'

# Without authentication (if server auth is disabled)
curl -X POST http://localhost:8000/api/v1/packages \
  -H "Content-Type: application/json" \
  -d '{"name":"requests","version":"2.31.0","ecosystem":"pypi"}'
```

**Response:**

```json
{
  "message": "Package submitted successfully",
  "name": "requests",
  "status": "pending"
}
```

### Get Security Scan

**GET** `/security/scans/{name}`

Get security scan results for a package.

**Example:**

```bash
curl http://localhost:8000/api/v1/security/scans/flask
```

**Response:**

```json
{
  "package": "flask",
  "version": "2.3.0",
  "scan_date": "2024-01-16T10:00:00Z",
  "status": "passed",
  "vulnerabilities": [],
  "severity": {
    "critical": 0,
    "high": 0,
    "medium": 0,
    "low": 0
  },
  "tools_used": ["trivy", "grype", "osv-scanner"]
}
```

### Get License Information

**GET** `/licenses/{name}`

Get license information and compatibility.

**Example:**

```bash
curl http://localhost:8000/api/v1/licenses/Apache-2.0
```

**Response:**

```json
{
  "name": "Apache-2.0",
  "status": "approved",
  "category": "permissive",
  "compatible_with": ["MIT", "BSD-3-Clause", "GPL-3.0"],
  "incompatible_with": [],
  "requires_attribution": true,
  "allows_commercial": true,
  "url": "https://www.apache.org/licenses/LICENSE-2.0"
}
```

## Error Responses

All error responses follow this format:

```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {}
}
```

### Status Codes

- `200 OK`: Success
- `201 Created`: Resource created
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Missing API token
- `403 Forbidden`: Invalid API token
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource already exists
- `500 Internal Server Error`: Server error

## Rate Limiting

Current: No rate limiting (local development)

Production recommendations:

- 100 requests per minute per IP
- 1000 requests per hour per API key

## Versioning

API versions are specified in the URL path:

- `/api/v1/` - Version 1 (current)
- `/api/v2/` - Version 2 (future)

The API uses URL path versioning for clear version separation.

## Examples

### Python

```python
import requests
import os

# Get API token from environment
API_TOKEN = os.getenv('FOSS_API_TOKEN')

# Headers for authenticated requests
headers = {}
if API_TOKEN:
    headers['X-API-Key'] = API_TOKEN

# Search packages (public, no auth required)
response = requests.get(
    "http://localhost:8000/api/v1/packages",
    params={"search": "flask", "ecosystem": "pypi"}
)
packages = response.json()["packages"]

# Submit package (requires auth if enabled)
response = requests.post(
    "http://localhost:8000/api/v1/packages",
    headers=headers,
    json={
        "name": "requests",
        "version": "2.31.0",
        "ecosystem": "pypi"
    }
)
```

### JavaScript

```javascript
// Get API token from environment
const API_TOKEN = process.env.FOSS_API_TOKEN;

// Search packages (public, no auth required)
const response = await fetch(
  'http://localhost:8000/api/v1/packages?search=express&ecosystem=npm'
);
const data = await response.json();

// Submit package (requires auth if enabled)
const headers = { 'Content-Type': 'application/json' };
if (API_TOKEN) {
  headers['X-API-Key'] = API_TOKEN;
}

const submitResponse = await fetch(
  'http://localhost:8000/api/v1/packages',
  {
    method: 'POST',
    headers: headers,
    body: JSON.stringify({
      name: 'express',
      version: '4.18.0',
      ecosystem: 'npm'
    })
  }
);
```

### cURL

```bash
# List all packages
curl http://localhost:8000/api/v1/packages

# Search packages
curl "http://localhost:8000/api/v1/packages?search=flask"

# Get package details
curl http://localhost:8000/api/v1/packages/flask

# Submit package (with authentication)
curl -X POST http://localhost:8000/api/v1/packages \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $FOSS_API_TOKEN" \
  -d '{"name":"requests","version":"2.31.0","ecosystem":"pypi"}'

# Get security scan
curl http://localhost:8000/api/v1/security/scans/flask
```

## See Also

- [CLI Tool](cli-tool.md) - Command-line interface
- [API Reference](../api-reference.md) - Overview
- [FOSS Packages](../foss-packages.md) - Package management
