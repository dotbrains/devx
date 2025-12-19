import click
import subprocess
from pathlib import Path
from ..utils import success, error, info


@click.command()
@click.argument('package_name')
@click.argument('version')
@click.option('--reason', '-r', required=True, help='Rejection reason')
@click.pass_context
def reject(ctx, package_name, version, reason):
    """
    Reject a package (calls approval script with --reject)
    
    Examples:
      foss-cli reject vulnerable-pkg 1.0.0 --reason "Critical CVE"
      foss-cli reject old-package 0.5.0 --reason "Unmaintained"
    """
    # Find the scripts directory
    scripts_dir = Path(__file__).parent.parent.parent.parent / "scripts"
    approve_script = scripts_dir / "approve-package.sh"
    
    if not approve_script.exists():
        error(f"Approval script not found at {approve_script}")
        raise click.Abort()
    
    try:
        info(f"Rejecting {package_name}@{version}...")
        
        cmd = [
            str(approve_script),
            package_name,
            version,
            '--reject',
            '--reason',
            reason
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            success(f"Package {package_name}@{version} rejected")
            if result.stdout:
                click.echo(result.stdout)
        else:
            error(f"Rejection failed: {result.stderr}")
            raise click.Abort()
    
    except Exception as e:
        error(f"Rejection failed: {e}")
        raise click.Abort()
