# API Versioning Examples

Real-world examples of implementing API version changes.

## Example 1: Adding New Fields (Backward Compatible)

### Scenario
Add `download_count` and `popularity_score` to package responses in v2.

### Implementation

**Step 1: Create v2 schemas**

```bash
touch api/versions/v2/schemas.py
```

**api/versions/v2/schemas.py:**
```python
from pydantic import BaseModel
from typing import Optional

class PackageOutV2(BaseModel):
    """Enhanced package model for v2"""
    # All v1 fields
    name: str
    version: str
    type: str
    status: str
    
    # New v2 fields
    download_count: Optional[int] = 0
    popularity_score: Optional[float] = 0.0
```

**Step 2: Update v2 handler**

**api/versions/v2/routes/packages/handlers.py:**
```python
from ...v1.routes.packages.handlers import handle_list_packages as v1_list
from ..schemas import PackageOutV2

def handle_list_packages():
    """Enhanced v2 implementation with new fields"""
    v1_packages = v1_list()
    
    # Enhance with v2 fields
    v2_packages = []
    for pkg in v1_packages:
        v2_pkg = PackageOutV2(
            **pkg.dict(),
            download_count=fetch_downloads(pkg.name),
            popularity_score=calculate_popularity(pkg.name)
        )
        v2_packages.append(v2_pkg)
    
    return v2_packages
```

**Result:**
- v1 clients: Continue to work, ignore new fields
- v2 clients: Get enhanced data

## Example 2: Changing Endpoint Behavior (Breaking Change)

### Scenario
v1 returns all packages by default. v2 requires explicit filtering.

### Implementation

**api/versions/v2/routes/packages/router.py:**
```python
from fastapi import APIRouter, HTTPException, Query

router = APIRouter()

@router.get("/packages")
def list_packages(
    status: str = Query(..., description="Required in v2: approved|pending|rejected")
):
    """v2 requires explicit status filter"""
    if not status:
        raise HTTPException(
            status_code=400, 
            detail="status parameter is required in v2. Use v1 for unfiltered listing."
        )
    return handle_list_packages(status=status)
```

**Migration path:**
- v1: `GET /api/v1/packages` → returns all
- v2: `GET /api/v2/packages?status=approved` → requires filter

## Example 3: New Authentication Method

### Scenario
v1 uses API key in query. v2 uses Bearer token.

### Implementation

**api/versions/v2/dependencies.py:**
```python
from fastapi import Header, HTTPException

async def verify_token(authorization: str = Header(None)):
    """v2 authentication dependency"""
    if not authorization:
        raise HTTPException(401, "Authorization header required")
    
    if not authorization.startswith("Bearer "):
        raise HTTPException(401, "Invalid authorization format")
    
    token = authorization.replace("Bearer ", "")
    # Verify token
    if not is_valid_token(token):
        raise HTTPException(401, "Invalid token")
    
    return token
```

**api/versions/v2/routes/packages/router.py:**
```python
from fastapi import APIRouter, Depends
from ..dependencies import verify_token

router = APIRouter()

@router.get("/packages")
def list_packages(token: str = Depends(verify_token)):
    """Protected endpoint with v2 auth"""
    return handle_list_packages()
```

## Example 4: Deprecating Old Endpoints

### Scenario
Remove `/packages/all` endpoint in v2, merge into `/packages`.

### Implementation

**api/versions/v1/routes/packages/router.py:**
```python
from fastapi import APIRouter
import warnings

router = APIRouter()

@router.get("/packages/all")
def list_all_packages():
    """
    Deprecated: Use /packages instead.
    This endpoint will be removed in v2.
    """
    warnings.warn("Endpoint deprecated, use /packages", DeprecationWarning)
    # Add deprecation header
    return {
        "warning": "Endpoint deprecated. Use /packages in v2",
        "data": handle_list_packages()
    }
```

**api/versions/v2/routes/packages/router.py:**
```python
# /packages/all removed entirely

@router.get("/packages")
def list_packages():
    """Consolidated endpoint in v2"""
    return handle_list_packages()
```

## Example 5: Reusing Most of v1

### Scenario
v2 is mostly identical to v1, except for one new reports endpoint.

### Implementation

**api/versions/v2/router.py:**
```python
from fastapi import APIRouter
from ..v1.routes import packages, security, licenses  # Reuse v1
from .routes import reports  # New in v2

router = APIRouter()

# Reuse all v1 routes
router.include_router(packages.router, tags=["v2-Packages"])
router.include_router(security.router, tags=["v2-Security"])
router.include_router(licenses.router, tags=["v2-Licenses"])

# Add new v2-only route
router.include_router(reports.router, tags=["v2-Reports"])
```

This way you only maintain new code, not duplicate everything.

## Example 6: Field Renaming (Breaking Change)

### Scenario
Rename `security_score` to `risk_score` and invert values.

### Implementation

**api/versions/v2/schemas.py:**
```python
class PackageOutV2(BaseModel):
    name: str
    version: str
    risk_score: int  # Renamed and inverted: 100 - security_score
    
    @classmethod
    def from_v1(cls, v1_package):
        """Convert v1 package to v2 format"""
        return cls(
            name=v1_package.name,
            version=v1_package.version,
            risk_score=100 - v1_package.security_score  # Invert
        )
```

## Example 7: Pagination Changes

### Scenario
v1: Simple offset pagination. v2: Cursor-based pagination.

### Implementation

**api/versions/v1/routes/packages/router.py:**
```python
@router.get("/packages")
def list_packages(skip: int = 0, limit: int = 100):
    """v1: Offset pagination"""
    return handle_list_packages(skip=skip, limit=limit)
```

**api/versions/v2/routes/packages/router.py:**
```python
@router.get("/packages")
def list_packages(cursor: Optional[str] = None, limit: int = 100):
    """v2: Cursor-based pagination"""
    return handle_cursor_pagination(cursor=cursor, limit=limit)
```

## Testing Strategy

**tests/test_versions.py:**
```python
import pytest
from fastapi.testclient import TestClient
from api.app import app

client = TestClient(app)

class TestVersionCompatibility:
    """Ensure v2 doesn't break v1"""
    
    def test_v1_still_works(self):
        """v1 endpoints remain functional"""
        response = client.get("/api/v1/packages")
        assert response.status_code == 200
    
    def test_v2_enhanced_response(self):
        """v2 returns enhanced data"""
        response = client.get("/api/v2/packages")
        assert response.status_code == 200
        data = response.json()[0]
        assert "download_count" in data  # v2 field
        assert "popularity_score" in data  # v2 field
    
    def test_v1_v2_base_fields_match(self):
        """Common fields are consistent"""
        v1_resp = client.get("/api/v1/packages/requests")
        v2_resp = client.get("/api/v2/packages/requests")
        
        v1_data = v1_resp.json()[0]
        v2_data = v2_resp.json()[0]
        
        # Core fields should match
        assert v1_data["name"] == v2_data["name"]
        assert v1_data["version"] == v2_data["version"]
```

## Client Migration Example

**Python Client:**

```python
# v1 client
class FOSSClientV1:
    BASE_URL = "http://api.example.com/api/v1"
    
    def list_packages(self):
        response = requests.get(f"{self.BASE_URL}/packages")
        return response.json()

# v2 client
class FOSSClientV2:
    BASE_URL = "http://api.example.com/api/v2"
    
    def __init__(self, token):
        self.token = token
    
    def list_packages(self, status="approved"):
        headers = {"Authorization": f"Bearer {self.token}"}
        params = {"status": status}
        response = requests.get(
            f"{self.BASE_URL}/packages",
            headers=headers,
            params=params
        )
        return response.json()
```

## Gradual Migration

**Adapter Pattern for Compatibility:**

```python
# api/adapters.py
class APIAdapter:
    """Allows v1 clients to use v2 endpoints"""
    
    def __init__(self, version="v1"):
        self.version = version
    
    def list_packages(self, **kwargs):
        if self.version == "v1":
            # No auth required, no status filter
            return v1_list_packages()
        elif self.version == "v2":
            # Auth required, status filter required
            return v2_list_packages(**kwargs)
```

This allows internal systems to gradually migrate from v1 to v2.
