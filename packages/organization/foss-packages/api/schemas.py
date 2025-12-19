from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime


class PackageSubmitIn(BaseModel):
    """Schema for submitting a new package"""
    name: str = Field(..., min_length=1, description="Package name")
    version: str = Field(..., min_length=1, description="Package version")
    type: str = Field(..., description="Package type: pypi, npm, maven, container, binary")
    description: Optional[str] = Field(None, description="Package description")
    upstream_url: Optional[str] = Field(None, description="Upstream URL")
    submitter: Optional[str] = Field(None, description="Submitter email")

    class Config:
        schema_extra = {
            "example": {
                "name": "requests",
                "version": "2.31.0",
                "type": "pypi",
                "description": "HTTP library for Python",
                "upstream_url": "https://pypi.org/project/requests/",
                "submitter": "dev@example.com"
            }
        }


class SubmitResponse(BaseModel):
    """Response after package submission"""
    message: str
    id: str
    status: str
    path: str
    queued_scan: bool


class VulnerabilityOut(BaseModel):
    """Vulnerability information"""
    id: str
    severity: str
    status: Optional[str] = None
    justification: Optional[str] = None


class PackageOut(BaseModel):
    """Schema for package output"""
    name: str
    version: str
    type: str
    license: Optional[str] = None
    status: str
    security_scan_date: Optional[str] = None
    security_score: Optional[int] = None
    vulnerabilities: List[VulnerabilityOut] = []
    approved_by: Optional[str] = None
    approved_date: Optional[str] = None
    description: Optional[str] = None
    upstream_url: Optional[str] = None
    mirror_url: Optional[str] = None
    dependencies: List[str] = []

    @classmethod
    def from_registry(cls, data: Dict[str, Any]) -> "PackageOut":
        """Convert registry dict to PackageOut"""
        # Handle vulnerabilities
        vulns_raw = data.get("vulnerabilities", [])
        vulns = []
        if isinstance(vulns_raw, list):
            for v in vulns_raw:
                if isinstance(v, dict):
                    vulns.append(VulnerabilityOut(**v))

        return cls(
            name=data.get("name", ""),
            version=data.get("version", ""),
            type=data.get("type", ""),
            license=data.get("license"),
            status=data.get("status", "unknown"),
            security_scan_date=data.get("security_scan_date"),
            security_score=data.get("security_score"),
            vulnerabilities=vulns,
            approved_by=data.get("approved_by"),
            approved_date=data.get("approved_date"),
            description=data.get("description"),
            upstream_url=data.get("upstream_url"),
            mirror_url=data.get("mirror_url"),
            dependencies=data.get("dependencies", []),
        )


class ScanSummaryOut(BaseModel):
    """Security scan summary"""
    scan_id: str
    package: str
    version: str
    scan_date: str
    security_score: int
    vulnerabilities: Dict[str, int]
    approval_recommended: bool
    scan_tools: List[str]
    report_path: str


class LicenseOut(BaseModel):
    """License information"""
    name: str
    spdx_id: Optional[str] = None
    category: str
    risk_level: str
    commercial_use: bool
    modification: bool
    distribution: bool
    patent_grant: bool
    notes: Optional[str] = None
    compatible_with: List[str] = []
    incompatible_with: List[str] = []
