# API Versioning Guide

This guide explains how to add and manage API versions in the FOSS Package API.

## Directory Structure

```
api/
├── app.py                      # Main application
├── config.py                   # Shared configuration
├── schemas.py                  # Shared base schemas (optional)
├── storage.py                  # Shared storage layer
│
└── versions/                   # API versions
    ├── __init__.py
    │
    ├── v1/                     # Version 1
    │   ├── __init__.py
    │   ├── router.py           # v1 router aggregator
    │   ├── schemas.py          # v1-specific schemas (optional)
    │   └── routes/
    │       ├── __init__.py
    │       ├── packages/
    │       ├── security/
    │       └── licenses/
    │
    └── v2/                     # Version 2 (future)
        ├── __init__.py
        ├── router.py
        ├── schemas.py
        └── routes/
            └── ...
```

## Creating a New API Version

### Option 1: Copy and Modify (Breaking Changes)

Use this when you need breaking changes that aren't backward compatible.

```bash
# 1. Copy the previous version
cp -r api/versions/v1 api/versions/v2

# 2. Update v2/__init__.py
cat > api/versions/v2/__init__.py << 'EOF'
"""
API Version 2

Major version with breaking changes from v1.
"""

from .router import router

__all__ = ["router"]
EOF

# 3. Modify routes, schemas, handlers as needed
# Make your breaking changes in v2/routes/

# 4. Register v2 in app.py
# Add to api/app.py:
from .versions import v1, v2

app.include_router(v1.router, prefix="/api/v1")
app.include_router(v2.router, prefix="/api/v2")
```

### Option 2: Incremental Evolution (Backward Compatible)

Use this for adding new endpoints without breaking existing ones.

```bash
# 1. Create new version directory
mkdir -p api/versions/v2/routes

# 2. Reuse v1 routes and add new ones
cat > api/versions/v2/router.py << 'EOF'
from fastapi import APIRouter
from ..v1.routes import packages, security, licenses  # Reuse v1
from .routes import reports  # New in v2

router = APIRouter()

# Include v1 routes (unchanged)
router.include_router(packages.router, tags=["v2-Packages"])
router.include_router(security.router, tags=["v2-Security"])
router.include_router(licenses.router, tags=["v2-Licenses"])

# Include new v2 routes
router.include_router(reports.router, tags=["v2-Reports"])
EOF

# 3. Add only new functionality in v2/routes/
# e.g., create api/versions/v2/routes/reports/
```

## Version-Specific Changes

### 1. Add New Endpoints

```bash
# Create new route in v2
mkdir -p api/versions/v2/routes/reports
touch api/versions/v2/routes/reports/{__init__.py,router.py,handlers.py}
```

**api/versions/v2/routes/reports/router.py:**
```python
from fastapi import APIRouter

router = APIRouter()

@router.get("/reports/security")
def generate_security_report():
    return {"report": "data"}
```

### 2. Modify Existing Endpoints

**api/versions/v2/routes/packages/router.py:**
```python
from fastapi import APIRouter

router = APIRouter()

@router.get("/packages")
def list_packages():
    # v2-specific changes
    # e.g., different default sorting, new fields, etc.
    return enhanced_package_list()
```

### 3. Update Response Models

**api/versions/v2/schemas.py:**
```python
from pydantic import BaseModel
from typing import Optional

class PackageOutV2(BaseModel):
    """Enhanced package model for v2"""
    name: str
    version: str
    # New fields in v2
    download_count: Optional[int] = None
    popularity_score: Optional[float] = None
```

## Version Lifecycle Management

### Deprecation Strategy

**1. Announce Deprecation**

Add deprecation notice to v1:

```python
# api/versions/v1/router.py
from fastapi import APIRouter
from fastapi.responses import JSONResponse

router = APIRouter()

@router.get("/")
def version_info():
    return {
        "version": "v1",
        "status": "deprecated",
        "deprecation_date": "2025-06-01",
        "sunset_date": "2025-12-01",
        "message": "Please migrate to v2",
        "migration_guide": "/api/docs/migration-v1-to-v2"
    }
```

**2. Add Deprecation Header**

```python
# api/versions/v1/router.py
from fastapi import APIRouter, Response

@router.get("/packages")
def list_packages(response: Response):
    response.headers["Deprecation"] = "true"
    response.headers["Sunset"] = "Wed, 01 Dec 2025 00:00:00 GMT"
    response.headers["Link"] = '</api/v2/packages>; rel="successor-version"'
    # ... endpoint logic
```

**3. Remove Old Version**

```python
# app.py - after sunset date
# Remove: app.include_router(v1.router, prefix="/api/v1")
app.include_router(v2.router, prefix="/api/v2")
```

## Version Selection Strategies

### 1. URL Path Versioning (Current)

```
GET /api/v1/packages
GET /api/v2/packages
```

**Pros:** Clear, cacheable, easy to understand
**Cons:** More URLs to manage

### 2. Header Versioning (Alternative)

```python
# app.py
from fastapi import Header, HTTPException

@app.get("/api/packages")
def packages(api_version: str = Header(default="v1")):
    if api_version == "v1":
        return v1_packages()
    elif api_version == "v2":
        return v2_packages()
    raise HTTPException(400, "Invalid API version")
```

### 3. Content Negotiation (Alternative)

```python
from fastapi import Request

@app.get("/api/packages")
def packages(request: Request):
    accept = request.headers.get("Accept")
    if "application/vnd.foss.v2+json" in accept:
        return v2_packages()
    return v1_packages()
```

## Testing Multiple Versions

```python
# tests/test_versions.py
from fastapi.testclient import TestClient
from api.app import app

client = TestClient(app)

def test_v1_packages():
    response = client.get("/api/v1/packages")
    assert response.status_code == 200

def test_v2_packages():
    response = client.get("/api/v2/packages")
    assert response.status_code == 200
    # v2-specific assertions
    assert "download_count" in response.json()[0]
```

## Migration Guide Template

Create migration guides for users:

**docs/migrations/v1-to-v2.md:**
```markdown
# Migrating from v1 to v2

## Breaking Changes

### 1. Package Response Format
- Added: `download_count`, `popularity_score`
- Removed: `mirror_url` (use `mirrors` array instead)
- Changed: `status` enum values

### 2. Authentication
- v1: API key in query parameter
- v2: Bearer token in Authorization header

## Migration Steps

1. Update base URL: `/api/v1` → `/api/v2`
2. Update response parsing to handle new fields
3. Change authentication method
4. Test in staging environment

## Examples

### v1 Request
```bash
curl "http://api.example.com/api/v1/packages?api_key=xxx"
```

### v2 Request
```bash
curl "http://api.example.com/api/v2/packages" \
  -H "Authorization: Bearer xxx"
```
```

## Best Practices

1. **Semantic Versioning**
   - v1: Initial release
   - v2: Major breaking changes
   - Use minor versions for backward-compatible additions

2. **Keep v1 Simple**
   - Don't backport new features to old versions
   - Only apply critical security fixes

3. **Documentation**
   - Maintain separate docs for each version
   - Clearly mark deprecated endpoints
   - Provide migration guides

4. **Deprecation Timeline**
   - Announce: 6 months before sunset
   - Deprecate: Mark as deprecated
   - Sunset: Remove after deprecation period

5. **Shared Code**
   - Storage layer can be shared
   - Configuration can be shared
   - Business logic should be version-specific if behavior differs

## Common Patterns

### Reuse with Override

```python
# v2/routes/packages/router.py
from fastapi import APIRouter
from ...v1.routes.packages import handlers as v1_handlers

router = APIRouter()

@router.get("/packages")
def list_packages(enhanced: bool = False):
    if not enhanced:
        # Reuse v1 logic
        return v1_handlers.handle_list_packages()
    
    # New v2 enhanced logic
    return handle_enhanced_packages()
```

### Adapter Pattern

```python
# v2/adapters.py
from ..v1.schemas import PackageOut as PackageOutV1
from .schemas import PackageOutV2

def adapt_v1_to_v2(v1_package: PackageOutV1) -> PackageOutV2:
    """Convert v1 package to v2 format"""
    return PackageOutV2(
        **v1_package.dict(),
        download_count=fetch_download_count(v1_package.name),
        popularity_score=calculate_popularity(v1_package)
    )
```

## Quick Reference

```bash
# Create new version
make new-version VERSION=v2

# Test specific version
pytest tests/test_v2.py

# Check version compatibility
make check-compatibility FROM=v1 TO=v2

# Generate migration guide
make migration-guide FROM=v1 TO=v2
```
