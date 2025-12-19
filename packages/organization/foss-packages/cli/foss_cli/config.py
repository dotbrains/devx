import os
from dataclasses import dataclass


@dataclass
class Config:
    """CLI configuration"""
    api_url: str
    api_token: str = ""
    verbose: bool = False
    output_json: bool = False
    
    @property
    def base_url(self) -> str:
        """Get base API URL"""
        return f"{self.api_url}/api/v1"
    
    @property
    def has_token(self) -> bool:
        """Check if API token is configured"""
        return bool(self.api_token and self.api_token.strip())
    
    @classmethod
    def from_env(cls):
        """Create config from environment variables"""
        return cls(
            api_url=os.getenv('FOSS_API_URL', 'http://localhost:8000'),
            api_token=os.getenv('FOSS_API_TOKEN', ''),
            verbose=os.getenv('FOSS_VERBOSE', '').lower() == 'true',
            output_json=os.getenv('FOSS_JSON', '').lower() == 'true'
        )
