from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .config import settings
from .versions import v1
from .middleware import AuthLoggingMiddleware
from .auth import token_manager

app = FastAPI(
    title="FOSS Package API",
    version="1.0.0",
    description="REST API for managing the FOSS package ecosystem",
    openapi_url="/api/openapi.json",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
)

# CORS (restrict in production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Authentication logging middleware
app.add_middleware(AuthLoggingMiddleware)

# Include API versions
app.include_router(v1.router, prefix="/api/v1")


@app.get("/", tags=["Root"])
def root():
    """API root endpoint"""
    return {
        "name": "FOSS Package API",
        "version": "1.0.0",
        "docs": "/api/docs",
        "openapi": "/api/openapi.json",
        "authentication": "enabled" if token_manager.is_auth_enabled else "disabled",
    }


@app.get("/health", tags=["Health"])
def health_check():
    """Health check endpoint for monitoring"""
    return {"status": "healthy", "service": "foss-api"}
