from typing import List, Optional
from ...schemas import ScanSummaryOut
from ...storage import list_scans_for_package


def handle_list_scans(pkg_name: str, version: Optional[str] = None) -> List[ScanSummaryOut]:
    """Handle listing security scans for a package"""
    scans = list_scans_for_package(pkg_name, version)
    # Return empty list instead of error for better API experience
    return scans
