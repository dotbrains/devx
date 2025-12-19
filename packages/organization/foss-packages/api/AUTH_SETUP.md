# API Authentication Setup Guide

This guide will help you set up and use API token authentication for the FOSS Package API.

## Quick Start

### 1. Generate an API Token

Generate a secure token using Python:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Example output:
```
x7jK9mN2pQ4rT8vW1yZ3bD5fH6gJ8kL0nM2oP4qR6sT8uV0wX2yZ4aB6cD8eF0g
```

### 2. Set Environment Variable

Add the token to your environment:

```bash
# Linux/Mac - Add to ~/.bashrc or ~/.zshrc
export FOSS_API_TOKENS="x7jK9mN2pQ4rT8vW1yZ3bD5fH6gJ8kL0nM2oP4qR6sT8uV0wX2yZ4aB6cD8eF0g"

# Or set multiple tokens (comma-separated)
export FOSS_API_TOKENS="token1,token2,token3"

# For the current session only
export FOSS_API_TOKENS="your-token-here"
```

For production, use a `.env` file or secrets manager:

```bash
# .env file
FOSS_API_TOKENS="production-token-1,production-token-2"
```

### 3. Start the API

```bash
cd packages/organization/foss-packages/api
./run.sh
```

### 4. Test Authentication

**Check authentication status:**
```bash
curl http://localhost:8000/
```

**Submit a package with authentication:**
```bash
curl -X POST "http://localhost:8000/api/v1/packages" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: x7jK9mN2pQ4rT8vW1yZ3bD5fH6gJ8kL0nM2oP4qR6sT8uV0wX2yZ4aB6cD8eF0g" \
  -d '{
    "name": "test-package",
    "version": "1.0.0",
    "type": "pypi",
    "description": "Test package"
  }'
```

## Authentication Behavior

### Development Mode (No Auth)
When `FOSS_API_TOKENS` is empty or not set, authentication is **disabled**:
- All endpoints are accessible without tokens
- Useful for local development and testing

### Production Mode (Auth Enabled)
When `FOSS_API_TOKENS` contains one or more tokens:
- Write operations require a valid API token
- Read operations remain public
- Invalid tokens return 403 Forbidden
- Missing tokens return 401 Unauthorized

## Endpoints

### Protected Endpoints
These require the `X-API-Key` header:
- `POST /api/v1/packages` - Submit new packages

### Public Endpoints
No authentication required:
- `GET /api/v1/packages` - List all packages
- `GET /api/v1/packages/{name}` - Get package details
- `GET /api/v1/security/scans/{name}` - Get security scans
- `GET /api/v1/licenses/{name}` - Get license info
- `GET /health` - Health check
- `GET /` - API root

## Usage Examples

### Python

```python
import requests
import os

API_KEY = os.getenv("FOSS_API_TOKEN")
BASE_URL = "http://localhost:8000/api/v1"

headers = {"X-API-Key": API_KEY}

# Submit package
response = requests.post(
    f"{BASE_URL}/packages",
    json={
        "name": "requests",
        "version": "2.31.0",
        "type": "pypi",
        "description": "HTTP library"
    },
    headers=headers
)
print(response.json())
```

### JavaScript/TypeScript

```typescript
const API_KEY = process.env.FOSS_API_TOKEN;
const BASE_URL = 'http://localhost:8000/api/v1';

async function submitPackage(data: any) {
  const response = await fetch(`${BASE_URL}/packages`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-API-Key': API_KEY!
    },
    body: JSON.stringify(data)
  });
  return response.json();
}
```

### Curl

```bash
# Set your token
API_KEY="your-token-here"

# Submit package
curl -X POST "http://localhost:8000/api/v1/packages" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d @package.json
```

## Security Best Practices

1. **Never commit tokens to version control**
   - Use `.env` files and add them to `.gitignore`
   - Use environment variables or secrets managers

2. **Use strong, random tokens**
   - Minimum 32 characters
   - Use `secrets.token_urlsafe()` to generate

3. **Rotate tokens regularly**
   - Update tokens every 90 days
   - Revoke old tokens after rotation

4. **Use different tokens per environment**
   - Separate tokens for dev, staging, production
   - Separate tokens per service/user

5. **Enable HTTPS in production**
   - Always use HTTPS to prevent token interception
   - Configure reverse proxy with SSL/TLS

6. **Monitor token usage**
   - Check logs for unauthorized access attempts
   - The API logs all requests with auth status

## Troubleshooting

### 401 Unauthorized
```json
{"detail": "Missing API key. Provide X-API-Key header."}
```
**Solution**: Add the `X-API-Key` header to your request

### 403 Forbidden
```json
{"detail": "Invalid API key"}
```
**Solution**: Check that your token matches one in `FOSS_API_TOKENS`

### Authentication Always Disabled
**Solution**: Ensure `FOSS_API_TOKENS` environment variable is set and contains at least one token

### Token Not Working
1. Check the token has no extra spaces or newlines
2. Verify the environment variable is loaded: `echo $FOSS_API_TOKENS`
3. Restart the API server after changing tokens
4. Check API logs for authentication attempts

## Multiple Tokens

You can configure multiple tokens for different services or users:

```bash
export FOSS_API_TOKENS="frontend-service-token,backend-service-token,admin-token"
```

Each token is validated independently. This allows you to:
- Issue different tokens to different teams
- Rotate tokens for specific services
- Revoke individual tokens without affecting others

## Disabling Authentication

To disable authentication (development only):

```bash
unset FOSS_API_TOKENS
# or
export FOSS_API_TOKENS=""
```

The API will log: `Auth: disabled` in the root endpoint response.

⚠️ **Warning**: Never disable authentication in production!
