import click
import subprocess
from pathlib import Path
from ..utils import success, error, info


@click.command()
@click.argument('package_name')
@click.argument('version')
@click.option('--notes', '-n', help='Approval notes')
@click.pass_context
def approve(ctx, package_name, version, notes):
    """
    Approve a package for use (calls approval script)
    
    Examples:
      foss-cli approve requests 2.31.0
      foss-cli approve flask 3.0.0 --notes "Security review complete"
    """
    # Find the scripts directory
    scripts_dir = Path(__file__).parent.parent.parent.parent / "scripts"
    approve_script = scripts_dir / "approve-package.sh"
    
    if not approve_script.exists():
        error(f"Approval script not found at {approve_script}")
        raise click.Abort()
    
    try:
        info(f"Approving {package_name}@{version}...")
        
        cmd = [str(approve_script), package_name, version]
        if notes:
            cmd.extend(['--notes', notes])
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            success(f"Package {package_name}@{version} approved!")
            if result.stdout:
                click.echo(result.stdout)
        else:
            error(f"Approval failed: {result.stderr}")
            raise click.Abort()
    
    except Exception as e:
        error(f"Approval failed: {e}")
        raise click.Abort()
