import os
import subprocess
from pathlib import Path


class Settings:
    """Application settings"""

    # API Configuration
    host: str = os.getenv("FOSS_API_HOST", "0.0.0.0")
    port: int = int(os.getenv("FOSS_API_PORT", "8000"))
    reload: bool = os.getenv("FOSS_API_RELOAD", "true").lower() == "true"

    # Authentication
    # Comma-separated list of valid API tokens
    # Example: FOSS_API_TOKENS="token1,token2,token3"
    # Leave empty to disable authentication (development only)
    api_tokens: str = os.getenv("FOSS_API_TOKENS", "")
    require_auth: bool = os.getenv("FOSS_REQUIRE_AUTH", "false").lower() == "true"

    # CORS
    cors_allow_origins: list = os.getenv("FOSS_CORS_ORIGINS", "http://localhost:3000,http://localhost:8000").split(",")

    # Scanning
    enable_scan_on_submit: bool = os.getenv("FOSS_SCAN_ON_SUBMIT", "true").lower() == "true"
    scan_script_path: Path = Path(__file__).parent.parent / "scripts" / "security-scan.sh"

    def trigger_scan(self, package_name: str, version: str):
        """
        Trigger a security scan for a package.
        This is called as a background task after package submission.
        """
        if not self.scan_script_path.exists():
            print(f"Scan script not found at {self.scan_script_path}")
            return

        try:
            subprocess.Popen(
                [str(self.scan_script_path), package_name, version],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
        except Exception as e:
            print(f"Failed to trigger scan: {e}")


settings = Settings()
