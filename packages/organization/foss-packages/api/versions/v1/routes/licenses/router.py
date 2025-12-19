from fastapi import APIRouter, HTTPException
from .handlers import handle_get_license
from ...schemas import LicenseOut

router = APIRouter()


@router.get("/licenses/{license_name}", response_model=LicenseOut)
def get_license(license_name: str):
    """
    Get license information by name or SPDX ID.
    
    - **license_name**: License name (e.g., "MIT") or SPDX ID (e.g., "Apache-2.0")
    
    Returns:
    - License details
    - Risk level assessment
    - Usage permissions
    - Compatibility information
    """
    info = handle_get_license(license_name)
    if not info:
        raise HTTPException(status_code=404, detail="License not found")
    return info
