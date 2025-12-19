import click
from ..client import APIClient
from ..utils import output_json, format_package_info, error, console


@click.command()
@click.argument('package_name')
@click.argument('version', required=False)
@click.pass_context
def info(ctx, package_name, version):
    """
    Get detailed information about a package
    
    Examples:
      foss-cli info requests
      foss-cli info requests 2.31.0
      foss-cli info flask 3.0.0
    """
    config = ctx.obj['config']
    client = APIClient(config.base_url, api_token=config.api_token)
    
    try:
        packages = client.get_package(package_name, version=version)
        
        if not packages:
            error(f"Package '{package_name}' not found")
            raise click.Abort()
        
        if config.output_json:
            output_json(packages)
        else:
            for i, pkg in enumerate(packages):
                if i > 0:
                    console.print("")  # Separator between versions
                console.print(format_package_info(pkg))
    
    except Exception as e:
        error(f"Failed to get package info: {e}")
        raise click.Abort()
