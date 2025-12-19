"""
API Versions

Each version is self-contained with its own routes, handlers, and schemas.
This allows for independent evolution and deprecation of API versions.
"""

from . import v1

__all__ = ["v1"]
