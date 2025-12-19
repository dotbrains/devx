from fastapi import APIRouter
from .routes import packages, security, licenses

# Create v1 router
router = APIRouter()

# Include all v1 routes
router.include_router(packages.router, tags=["v1-Packages"])
router.include_router(security.router, tags=["v1-Security"])
router.include_router(licenses.router, tags=["v1-Licenses"])
