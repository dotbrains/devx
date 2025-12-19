import click
from ..client import APIClient
from ..utils import output_json, format_scan_result, error, warning, console


@click.command()
@click.argument('package_name')
@click.argument('version', required=False)
@click.pass_context
def security(ctx, package_name, version):
    """
    Get security scan results for a package
    
    Examples:
      foss-cli security requests
      foss-cli security requests 2.31.0
      foss-cli security flask --json
    """
    config = ctx.obj['config']
    client = APIClient(config.base_url, api_token=config.api_token)
    
    try:
        scans = client.get_security_scans(package_name, version=version)
        
        if not scans:
            warning(f"No security scans found for '{package_name}'")
            return
        
        if config.output_json:
            output_json(scans)
        else:
            for i, scan in enumerate(scans):
                if i > 0:
                    console.print("\n" + "─" * 60 + "\n")
                console.print(format_scan_result(scan))
    
    except Exception as e:
        error(f"Failed to get security scans: {e}")
        raise click.Abort()
