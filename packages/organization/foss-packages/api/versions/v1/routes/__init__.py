"""
API Routes

Modular route organization:
- packages: Package management endpoints
- security: Security scan endpoints  
- licenses: License information endpoints
"""

from . import packages, security, licenses

__all__ = ["packages", "security", "licenses"]
