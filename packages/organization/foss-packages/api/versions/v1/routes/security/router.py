from fastapi import APIRouter
from typing import List, Optional
from .handlers import handle_list_scans
from ...schemas import ScanSummaryOut

router = APIRouter()


@router.get("/security/scans/{pkg_name}", response_model=List[ScanSummaryOut])
def list_scans(pkg_name: str, version: Optional[str] = None):
    """
    List security scans for a package.
    
    - **pkg_name**: Package name
    - **version**: Optional version filter
    
    Returns scan results including:
    - Security scores
    - Vulnerability counts by severity
    - Scan tools used
    - Approval recommendations
    """
    return handle_list_scans(pkg_name, version)
