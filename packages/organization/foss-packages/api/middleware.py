"""
Middleware for authentication and request logging.
"""
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
import time


class AuthLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware to log authentication attempts and requests"""

    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        
        # Log authentication header presence
        api_key = request.headers.get("X-API-Key")
        has_auth = "yes" if api_key else "no"
        
        # Process request
        response = await call_next(request)
        
        # Calculate request duration
        duration = time.time() - start_time
        
        # Log request info
        print(
            f"{request.method} {request.url.path} - "
            f"Auth: {has_auth} - "
            f"Status: {response.status_code} - "
            f"Duration: {duration:.3f}s"
        )
        
        return response
