from typing import Optional
from ...schemas import LicenseOut
from ...storage import get_license_info


def handle_get_license(license_name: str) -> Optional[LicenseOut]:
    """Handle getting license information"""
    return get_license_info(license_name)
