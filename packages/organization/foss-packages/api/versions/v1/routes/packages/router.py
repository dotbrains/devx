from fastapi import APIRouter, HTTPException, Query, BackgroundTasks, Depends
from typing import List, Optional
from .handlers import (
    handle_list_packages,
    handle_get_package,
    handle_submit_package,
)
from ...schemas import PackageOut, PackageSubmitIn, SubmitResponse
from ...auth import verify_api_key

router = APIRouter()


@router.get("/packages", response_model=List[PackageOut])
def list_packages(
    q: Optional[str] = Query(None, description="Search by name substring"),
    type: Optional[str] = Query(None, description="Package type: pypi|npm|maven|container|binary"),
    status: Optional[str] = Query(None, description="Status: approved|pending|rejected"),
    name: Optional[str] = Query(None, description="Exact package name"),
    version: Optional[str] = Query(None, description="Exact version"),
):
    """
    List all packages with optional filtering.
    
    - **q**: Search by package name substring
    - **type**: Filter by package type (pypi, npm, maven, container, binary)
    - **status**: Filter by status (approved, pending, rejected)
    - **name**: Filter by exact package name
    - **version**: Filter by exact version
    """
    return handle_list_packages(q=q, type=type, status=status, name=name, version=version)


@router.get("/packages/{pkg_name}", response_model=List[PackageOut])
def get_package(pkg_name: str, version: Optional[str] = None):
    """
    Get package(s) by name.
    
    - **pkg_name**: Package name
    - **version**: Optional version filter
    
    Returns all versions if version not specified.
    """
    results = handle_get_package(pkg_name, version)
    if not results:
        raise HTTPException(status_code=404, detail="Package not found")
    return results


@router.post("/packages", response_model=SubmitResponse, status_code=201, dependencies=[Depends(verify_api_key)])
def submit_package(payload: PackageSubmitIn, tasks: BackgroundTasks):
    """
    Submit a new package for security review and approval.
    
    The package will be queued for automated security scanning.
    
    **Authentication Required**: This endpoint requires a valid API key.
    """
    try:
        return handle_submit_package(payload, tasks)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
