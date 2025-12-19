"""
Authentication module for API token validation.

Supports custom API tokens for securing endpoints.
"""
import os
import secrets
from typing import Optional, Set
from fastapi import HTTPException, Security, status
from fastapi.security import APIKeyHeader

# API Key Header
api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)


class TokenManager:
    """Manages API tokens for authentication"""

    def __init__(self):
        self._tokens: Set[str] = set()
        self._load_tokens_from_env()

    def _load_tokens_from_env(self):
        """Load API tokens from environment variable"""
        tokens_str = os.getenv("FOSS_API_TOKENS", "")
        if tokens_str:
            # Support comma-separated list of tokens
            self._tokens = {token.strip() for token in tokens_str.split(",") if token.strip()}

    def validate_token(self, token: str) -> bool:
        """Validate if a token is authorized"""
        if not self._tokens:
            # If no tokens configured, allow access (for development)
            return True
        return token in self._tokens

    def add_token(self, token: str):
        """Add a new token (for runtime management)"""
        self._tokens.add(token)

    def remove_token(self, token: str):
        """Remove a token"""
        self._tokens.discard(token)

    def generate_token(self) -> str:
        """Generate a secure random token"""
        return secrets.token_urlsafe(32)

    @property
    def tokens(self) -> Set[str]:
        """Get all tokens (for admin purposes)"""
        return self._tokens.copy()

    @property
    def is_auth_enabled(self) -> bool:
        """Check if authentication is enabled"""
        return len(self._tokens) > 0


# Global token manager instance
token_manager = TokenManager()


async def verify_api_key(api_key: Optional[str] = Security(api_key_header)) -> str:
    """
    Verify API key dependency for FastAPI routes.
    
    Usage:
        @router.get("/protected", dependencies=[Depends(verify_api_key)])
        def protected_endpoint():
            return {"message": "Access granted"}
    
    Raises:
        HTTPException: If token is missing or invalid
    """
    if not token_manager.is_auth_enabled:
        # Auth disabled, allow access
        return "auth_disabled"

    if not api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing API key. Provide X-API-Key header.",
            headers={"WWW-Authenticate": "ApiKey"},
        )

    if not token_manager.validate_token(api_key):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid API key",
        )

    return api_key


async def optional_verify_api_key(api_key: Optional[str] = Security(api_key_header)) -> Optional[str]:
    """
    Optional API key verification for endpoints that can be public or authenticated.
    Returns the API key if valid, None if auth is disabled or no key provided.
    
    Does not raise exceptions for missing/invalid keys.
    """
    if not token_manager.is_auth_enabled:
        return None

    if not api_key:
        return None

    if token_manager.validate_token(api_key):
        return api_key

    return None
