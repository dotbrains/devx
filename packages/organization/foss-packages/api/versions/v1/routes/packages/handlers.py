from typing import List, Optional, Dict, Any
from fastapi import BackgroundTasks
from ...schemas import PackageOut, PackageSubmitIn, SubmitResponse
from ...storage import list_packages as storage_list_packages
from ...storage import get_package_by_name, submit_package as storage_submit_package
from ...config import settings


def handle_list_packages(
    q: Optional[str] = None,
    type: Optional[str] = None,
    status: Optional[str] = None,
    name: Optional[str] = None,
    version: Optional[str] = None,
) -> List[PackageOut]:
    """Handle package listing with filters"""
    pkgs = storage_list_packages()

    def match(p: Dict[str, Any]) -> bool:
        if q and q.lower() not in p.get("name", "").lower():
            return False
        if type and p.get("type") != type:
            return False
        if status and p.get("status") != status:
            return False
        if name and p.get("name") != name:
            return False
        if version and p.get("version") != version:
            return False
        return True

    return [PackageOut.from_registry(p) for p in pkgs if match(p)]


def handle_get_package(pkg_name: str, version: Optional[str] = None) -> List[PackageOut]:
    """Handle getting package by name"""
    results = get_package_by_name(pkg_name, version=version)
    return [PackageOut.from_registry(p) for p in results]


def handle_submit_package(payload: PackageSubmitIn, tasks: BackgroundTasks) -> SubmitResponse:
    """Handle package submission"""
    submission = storage_submit_package(payload)

    # Trigger background scan if enabled
    if settings.enable_scan_on_submit:
        tasks.add_task(settings.trigger_scan, payload.name, payload.version)

    return SubmitResponse(
        message="Package submission accepted",
        id=submission["id"],
        status="pending",
        path=str(submission["path"]),
        queued_scan=settings.enable_scan_on_submit,
    )
