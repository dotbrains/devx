import click
from ..client import APIClient
from ..utils import output_json, output_table, error


@click.command()
@click.argument('query')
@click.option('--type', '-t', help='Filter by package type (pypi, npm, maven, container, binary)')
@click.option('--status', '-s', help='Filter by status (approved, pending, rejected)')
@click.pass_context
def search(ctx, query, type, status):
    """
    Search for packages by name
    
    Examples:
      foss-cli search flask
      foss-cli search requests --type pypi
      foss-cli search nginx --status approved
    """
    config = ctx.obj['config']
    client = APIClient(config.base_url, api_token=config.api_token)
    
    try:
        packages = client.list_packages(query=query, type=type, status=status)
        
        if config.output_json:
            output_json(packages)
        else:
            columns = ['name', 'version', 'type', 'status', 'security_score']
            output_table(packages, columns, title=f"Search Results for '{query}'")
    
    except Exception as e:
        error(f"Search failed: {e}")
        raise click.Abort()
