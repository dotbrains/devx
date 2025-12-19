import click
from ..client import APIClient
from ..utils import output_json, success, error, info


@click.command()
@click.argument('package_name')
@click.argument('version')
@click.option('--type', '-t', required=True, 
              type=click.Choice(['pypi', 'npm', 'maven', 'container', 'binary']),
              help='Package type')
@click.option('--description', '-d', default='', help='Package description')
@click.option('--upstream-url', '-u', default='', help='Upstream package URL')
@click.pass_context
def submit(ctx, package_name, version, type, description, upstream_url):
    """
    Submit a package for security review and approval
    
    Examples:
      foss-cli submit axios 1.6.2 --type npm
      foss-cli submit requests 2.31.0 --type pypi --description "HTTP library"
      foss-cli submit nginx 1.25.3 --type container --upstream-url "https://hub.docker.com/_/nginx"
    """
    config = ctx.obj['config']
    client = APIClient(config.base_url, api_token=config.api_token)
    
    try:
        if not config.has_token:
            click.echo("⚠️  Warning: No API token provided. Authentication may be required.", err=True)
            click.echo("   Set FOSS_API_TOKEN or use --token option.", err=True)
        
        info(f"Submitting {package_name}@{version} for review...")
        
        result = client.submit_package(
            name=package_name,
            version=version,
            type=type,
            description=description,
            upstream_url=upstream_url
        )
        
        if config.output_json:
            output_json(result)
        else:
            success(f"Package submitted successfully!")
            click.echo(f"  ID: {result.get('id')}")
            click.echo(f"  Status: {result.get('status')}")
            if result.get('queued_scan'):
                info("Security scan has been queued")
    
    except Exception as e:
        error(f"Submission failed: {e}")
        raise click.Abort()
