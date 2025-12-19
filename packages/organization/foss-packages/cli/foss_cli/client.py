import requests
from typing import List, Dict, Any, Optional


class APIClient:
    """Client for FOSS Package API"""
    
    def __init__(self, base_url: str, api_token: Optional[str] = None):
        self.base_url = base_url
        self.api_token = api_token
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'foss-cli/1.0.0'
        })
        
        # Add API token if provided
        if api_token:
            self.session.headers.update({
                'X-API-Key': api_token
            })
    
    def _request(self, method: str, endpoint: str, **kwargs) -> requests.Response:
        """Make HTTP request to API"""
        url = f"{self.base_url}{endpoint}"
        response = self.session.request(method, url, **kwargs)
        response.raise_for_status()
        return response
    
    def list_packages(self, query: Optional[str] = None, 
                     type: Optional[str] = None,
                     status: Optional[str] = None) -> List[Dict[str, Any]]:
        """List packages with optional filters"""
        params = {}
        if query:
            params['q'] = query
        if type:
            params['type'] = type
        if status:
            params['status'] = status
        
        response = self._request('GET', '/packages', params=params)
        return response.json()
    
    def get_package(self, name: str, version: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get package by name and optional version"""
        params = {}
        if version:
            params['version'] = version
        
        response = self._request('GET', f'/packages/{name}', params=params)
        return response.json()
    
    def submit_package(self, name: str, version: str, 
                      type: str, description: str = "",
                      upstream_url: str = "") -> Dict[str, Any]:
        """Submit a new package for approval"""
        data = {
            'name': name,
            'version': version,
            'type': type,
            'description': description,
            'upstream_url': upstream_url
        }
        
        response = self._request('POST', '/packages', json=data)
        return response.json()
    
    def get_security_scans(self, name: str, 
                          version: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get security scans for a package"""
        params = {}
        if version:
            params['version'] = version
        
        response = self._request('GET', f'/security/scans/{name}', params=params)
        return response.json()
    
    def get_license(self, license_name: str) -> Dict[str, Any]:
        """Get license information"""
        response = self._request('GET', f'/licenses/{license_name}')
        return response.json()
