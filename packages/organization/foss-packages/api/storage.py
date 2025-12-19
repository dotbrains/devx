import yaml
import json
from pathlib import Path
from typing import List, Dict, Any, Optional
from datetime import datetime
from .schemas import PackageSubmitIn, ScanSummaryOut, LicenseOut

# Paths relative to API directory
FOSS_ROOT = Path(__file__).parent.parent
REGISTRY_DIR = FOSS_ROOT / "registry"
PENDING_DIR = REGISTRY_DIR / "pending"
APPROVED_DIR = REGISTRY_DIR / "approved"
SECURITY_DIR = FOSS_ROOT / "security"
SCANS_DIR = SECURITY_DIR / "scans"
LICENSES_FILE = FOSS_ROOT / "licenses" / "approved-licenses.yml"


def load_yaml(path: Path) -> Dict[str, Any]:
    """Load YAML file safely"""
    if not path.exists():
        return {}
    with open(path, "r") as f:
        return yaml.safe_load(f) or {}


def save_yaml(path: Path, data: Dict[str, Any]) -> None:
    """Save data to YAML file"""
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w") as f:
        yaml.safe_dump(data, f, default_flow_style=False, sort_keys=False)


def list_packages() -> List[Dict[str, Any]]:
    """
    List all packages from registry (approved, pending, rejected).
    Returns a list of package dicts.
    """
    packages_file = REGISTRY_DIR / "packages.yml"
    data = load_yaml(packages_file)

    all_packages = []

    # Add approved packages
    for pkg in data.get("packages", []):
        all_packages.append(pkg)

    # Add pending packages
    for pkg in data.get("pending_packages", []):
        all_packages.append(pkg)

    # Add rejected packages
    for pkg in data.get("rejected_packages", []):
        all_packages.append(pkg)

    # Also scan pending directory for files not yet in main registry
    if PENDING_DIR.exists():
        for pending_file in PENDING_DIR.glob("*.yml"):
            pending_data = load_yaml(pending_file)
            # Only add if not already in main registry
            pkg_name = pending_data.get("name")
            pkg_version = pending_data.get("version")
            if not any(p.get("name") == pkg_name and p.get("version") == pkg_version for p in all_packages):
                all_packages.append(pending_data)

    return all_packages


def get_package_by_name(name: str, version: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    Get package(s) by name. If version is provided, filter to that version.
    Returns a list because multiple versions may exist.
    """
    all_pkgs = list_packages()
    results = [p for p in all_pkgs if p.get("name") == name]

    if version:
        results = [p for p in results if p.get("version") == version]

    return results


def submit_package(payload: PackageSubmitIn) -> Dict[str, Any]:
    """
    Submit a package for approval. Creates a pending submission file.
    Returns submission metadata.
    """
    PENDING_DIR.mkdir(parents=True, exist_ok=True)

    package_id = f"{payload.name}-{payload.version}"
    pending_file = PENDING_DIR / f"{package_id}.yml"

    # Check if already exists
    if pending_file.exists():
        raise ValueError(f"Package {package_id} already in pending queue")

    # Check if already approved
    existing = get_package_by_name(payload.name, payload.version)
    for pkg in existing:
        if pkg.get("status") == "approved":
            raise ValueError(f"Package {payload.name}@{payload.version} already approved")

    submission_time = datetime.utcnow().isoformat() + "Z"
    submission_date = datetime.utcnow().strftime("%Y-%m-%d")

    submission_data = {
        "name": payload.name,
        "version": payload.version,
        "type": payload.type,
        "status": "pending",
        "submitted_by": payload.submitter or "api-user@example.com",
        "submitted_date": submission_date,
        "submitted_time": submission_time,
        "description": payload.description or "",
        "upstream_url": payload.upstream_url or "",
        "scanning": {
            "status": "queued",
            "started_at": None,
            "completed_at": None,
        },
        "security_scan": {
            "status": "pending",
            "score": None,
            "vulnerabilities": [],
        },
        "license_check": {
            "status": "pending",
            "license": None,
            "approved": None,
        },
        "dependency_analysis": {
            "status": "pending",
            "dependencies": [],
        },
        "approval": {
            "status": "pending",
            "approved_by": None,
            "approved_date": None,
            "rejection_reason": None,
        },
    }

    save_yaml(pending_file, submission_data)

    return {
        "id": package_id,
        "path": pending_file,
    }


def list_scans_for_package(pkg_name: str, version: Optional[str] = None) -> List[ScanSummaryOut]:
    """
    List security scans for a given package (and optionally version).
    Scans are stored in security/scans/<package>-<version>-<timestamp>/report.json
    """
    if not SCANS_DIR.exists():
        return []

    results = []

    for scan_dir in SCANS_DIR.iterdir():
        if not scan_dir.is_dir():
            continue

        # Parse scan directory name: <package>-<version>-<timestamp>
        parts = scan_dir.name.split("-")
        if len(parts) < 3:
            continue

        # Extract package name (may have hyphens)
        # Heuristic: last two parts are version and timestamp
        scan_pkg = "-".join(parts[:-2])
        scan_ver = parts[-2]

        if scan_pkg != pkg_name:
            continue
        if version and scan_ver != version:
            continue

        # Try to load report.json
        report_json = scan_dir / "report.json"
        if not report_json.exists():
            continue

        try:
            with open(report_json, "r") as f:
                report_data = json.load(f)

            results.append(
                ScanSummaryOut(
                    scan_id=scan_dir.name,
                    package=report_data.get("package", scan_pkg),
                    version=report_data.get("version", scan_ver),
                    scan_date=report_data.get("scan_date", ""),
                    security_score=report_data.get("security_score", 0),
                    vulnerabilities=report_data.get("vulnerabilities", {}),
                    approval_recommended=report_data.get("approval_recommended", False),
                    scan_tools=report_data.get("scan_tools", []),
                    report_path=str(report_json),
                )
            )
        except Exception:
            # Skip if report can't be parsed
            continue

    return results


def get_license_info(license_name: str) -> Optional[LicenseOut]:
    """
    Get license information by name (e.g., "MIT", "Apache-2.0").
    """
    if not LICENSES_FILE.exists():
        return None

    data = load_yaml(LICENSES_FILE)

    # Search in approved_licenses
    for lic in data.get("approved_licenses", []):
        if lic.get("name") == license_name or lic.get("spdx_id") == license_name:
            # Get compatibility info from compatibility matrix if available
            compat = data.get("compatibility", {})
            lic_compat = compat.get(license_name, {})

            return LicenseOut(
                name=lic.get("name", ""),
                spdx_id=lic.get("spdx_id"),
                category=lic.get("category", ""),
                risk_level=lic.get("risk_level", "unknown"),
                commercial_use=lic.get("commercial_use", False),
                modification=lic.get("modification", False),
                distribution=lic.get("distribution", False),
                patent_grant=lic.get("patent_grant", False),
                notes=lic.get("notes"),
                compatible_with=lic_compat.get("compatible_with", []),
                incompatible_with=lic_compat.get("incompatible_with", []),
            )

    # Search in conditional_licenses
    for lic in data.get("conditional_licenses", []):
        if lic.get("name") == license_name or lic.get("spdx_id") == license_name:
            return LicenseOut(
                name=lic.get("name", ""),
                spdx_id=lic.get("spdx_id"),
                category=lic.get("category", ""),
                risk_level=lic.get("risk_level", "unknown"),
                commercial_use=False,  # Conditional licenses require review
                modification=False,
                distribution=False,
                patent_grant=False,
                notes=lic.get("notes"),
                compatible_with=[],
                incompatible_with=[],
            )

    return None
