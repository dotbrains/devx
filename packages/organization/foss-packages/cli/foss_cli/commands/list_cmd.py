import click
from ..client import APIClient
from ..utils import output_json, output_table, error


@click.command(name='list')
@click.option('--type', '-t', help='Filter by package type (pypi, npm, maven, container, binary)')
@click.option('--status', '-s', default='approved', help='Filter by status (approved, pending, rejected)')
@click.pass_context
def list_packages(ctx, type, status):
    """
    List all packages
    
    Examples:
      foss-cli list
      foss-cli list --type pypi
      foss-cli list --status pending
      foss-cli list --type npm --status approved
    """
    config = ctx.obj['config']
    client = APIClient(config.base_url, api_token=config.api_token)
    
    try:
        packages = client.list_packages(type=type, status=status)
        
        if config.output_json:
            output_json(packages)
        else:
            title = "Packages"
            if type:
                title += f" ({type})"
            if status:
                title += f" - {status.title()}"
            
            columns = ['name', 'version', 'type', 'status', 'security_score']
            output_table(packages, columns, title=title)
    
    except Exception as e:
        error(f"Failed to list packages: {e}")
        raise click.Abort()
